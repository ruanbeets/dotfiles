#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$ROOT/scripts/common.sh"
dry_run=false
skip_packages=false
terminal_only=false
for arg in "$@"; do
    case "$arg" in
        --dry-run) dry_run=true ;;
        --skip-packages) skip_packages=true ;;
        --terminal-only) terminal_only=true ;;
        --help|-h)
            echo 'Usage: ./install.sh [--dry-run] [--skip-packages] [--terminal-only]'
            exit 0 ;;
        *) echo "Unknown argument: $arg" >&2; exit 2 ;;
    esac
done
[[ $EUID -ne 0 ]] || { echo 'Run as your normal desktop user; sudo is only used for pacman.' >&2; exit 1; }
source /etc/os-release
[[ ${ID:-} == arch || ${ID:-} == cachyos || " ${ID_LIKE:-} " == *' arch '* ]] || {
    echo 'This installer requires Arch / CachyOS with KDE Plasma.' >&2; exit 1;
}
init_paths
mapfile -t packages < <(sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$ROOT/packages.txt")
for package in "${packages[@]}"; do
    [[ $package =~ ^[a-z0-9@._+-]+$ ]] || { echo "Invalid package: $package" >&2; exit 1; }
done
missing=()
for package in "${packages[@]}"; do
    if ! pacman -Q "$package" &>/dev/null; then missing+=("$package"); fi
done
if ((${#missing[@]})); then printf 'Missing packages: %s\n' "${missing[*]}"; else echo 'All requested packages are installed.'; fi
if $dry_run; then
    echo 'Would back up and deploy the terminal configuration, Tide/Fisher, Konsole, and KDE appearance.'
    echo 'Would install Fish plugins and TPM plugins from their tracked declarations.'
    echo 'Would configure Fastfetch, fzf, zoxide, Yazi, Lazygit, delta, tealdeer, and tmux.'
    echo 'No changes made.'
    exit 0
fi
if $skip_packages; then
    if ((${#missing[@]})); then echo 'Install missing packages before using --skip-packages.' >&2; exit 1; fi
elif ((${#missing[@]})); then
    # No database-only refresh (-Sy) and no unattended system upgrade.
    sudo pacman -S --needed "${packages[@]}"
fi
for command in fish kwriteconfig6 kreadconfig6 git; do
    command -v "$command" >/dev/null || { echo "Missing prerequisite: $command" >&2; exit 1; }
done
while IFS= read -r -d '' source; do fish --no-config --no-execute "$source"; done < <(find "$ROOT/config/fish" -name '*.fish' -print0)

init_backup
pacman -Q > "$BATCOMPUTER_BACKUP_DIR/packages-after.txt"
printf '%s\n' "${missing[@]}" > "$BATCOMPUTER_BACKUP_DIR/packages-added.txt"
while IFS= read -r -d '' source; do
    deploy_file "$source" "$CONFIG_HOME/${source#"$ROOT/config/"}"
done < <(find "$ROOT/config" -type f -print0 | sort -z)
for name in Batcomputer.profile Batcomputer.colorscheme; do
    deploy_file "$ROOT/konsole/$name" "$DATA_HOME/konsole/$name"
done

# Retire the old repository's explicit Pure prompt overrides after preserving
# them in the same private backup as the new configuration.
for stale in "$CONFIG_HOME/fish/functions/fish_prompt.fish"; do
    if [[ -f $stale ]] && ! grep -q '_tide_' "$stale"; then
        backup_file "$stale"
        rm -- "$stale"
        echo "Retired old prompt override: $stale"
    fi
done

# Fisher reads this tracked list and is the only Fish prompt/plugin manager.
# Both Fisher's installed-plugin list and Tide's universal settings live in
# Fish's private variable store, so preserve it before either command writes.
backup_file "$CONFIG_HOME/fish/fish_variables"
fish -c 'functions -q fisher' || { echo 'Fisher did not load from its package.' >&2; exit 1; }
mapfile -t desired_fish_plugins < <(sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$CONFIG_HOME/fish/fish_plugins")
installed_fish_plugins=$(fish -c 'fisher list' | tr '[:upper:]' '[:lower:]')
for plugin in "${desired_fish_plugins[@]}"; do
    [[ $plugin =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.@-]+$ ]] || { echo "Invalid Fish plugin: $plugin" >&2; exit 1; }
    normalized_plugin=$(tr '[:upper:]' '[:lower:]' <<< "$plugin")
    plugin_ready=true
    grep -Fixq -- "$normalized_plugin" <<< "$installed_fish_plugins" || plugin_ready=false
    if [[ $plugin == *tide* && ! -f $CONFIG_HOME/fish/functions/fish_prompt.fish ]]; then plugin_ready=false; fi
    if ! $plugin_ready; then
        fish -c "fisher install '$plugin'"
    fi
done
fish -c 'source "$__fish_config_dir/tide-config.fish"'

write_setting konsolerc 'Desktop Entry' DefaultProfile Batcomputer.profile
write_setting konsolerc TabBar TabBarVisibility ShowTabBarWhenNeeded
write_setting konsolerc TabBar ExpandTabWidth false
write_setting konsolerc TabBar NewTabButton true
write_setting konsolerc SplitView SplitViewVisibility ShowSplitHeaderWhenNeeded
write_setting konsolerc 'MainWindow' MenuBar Disabled

# TPM's declarations live in config/tmux/tmux.conf and this bootstrap simply
# materializes the manager and the declared plugins under the user's home.
tpm_dir="$HOME/.tmux/plugins/tpm"
if [[ ! -d $tpm_dir/.git ]]; then
    if [[ -e $tpm_dir ]]; then
        echo "TPM path exists but is not a Git checkout; leaving it untouched: $tpm_dir" >&2
    else
        mkdir -p "$(dirname "$tpm_dir")"
        git clone --depth 1 https://github.com/tmux-plugins/tpm.git "$tpm_dir"
    fi
fi
if [[ -x $tpm_dir/bin/install_plugins ]]; then
    "$tpm_dir/bin/install_plugins"
else
    echo 'TPM bootstrap skipped; run prefix + I inside tmux after resolving the TPM path.' >&2
fi

if ! $terminal_only; then bash "$ROOT/kde/apply.sh"; fi

# Refresh tealdeer pages only on first use; later updates remain user-controlled.
if command -v tldr >/dev/null && [[ ! -d ${XDG_CACHE_HOME:-$HOME/.cache}/tealdeer ]]; then
    tldr --update || echo 'Tealdeer cache update failed; run tldr --update later when online.' >&2
fi

if command -v fc-match >/dev/null && ! fc-match 'JetBrainsMono Nerd Font' | grep -qi 'JetBrainsMono Nerd Font'; then
    fc-cache -f >/dev/null
fi

# Validation is read-only and gives immediate feedback before the user opens a
# fresh terminal. No fastfetch banner is emitted from nested shells or tmux.
fish --no-config --no-execute "$CONFIG_HOME/fish/config.fish"
fastfetch --config "$CONFIG_HOME/fastfetch/config.jsonc" >/dev/null
lazygit --version >/dev/null
tmux -f "$CONFIG_HOME/tmux/tmux.conf" -L batcomputer-check new-session -d -s batcomputer-check
tmux -L batcomputer-check kill-server
printf 'Font match: %s\n' "$(fc-match 'JetBrainsMono Nerd Font' -f '%{family}')"
printf 'Terminal color mode: COLORTERM=truecolor; Konsole TERM is xterm-256color; tmux uses tmux-256color with RGB enabled.\n'
if [[ -f $CONFIG_HOME/fish/functions/fish_prompt.fish ]] && grep -q '_tide_' "$CONFIG_HOME/fish/functions/fish_prompt.fish"; then
    echo 'Tide: Fish prompt function installed.'
else
    echo 'Tide: prompt function not found after Fisher install.' >&2
    exit 1
fi
printf 'Konsole TERM currently in installer: %s\n' "${TERM:-unset}"
echo
echo "Installed this run: ${missing[*]:-(none)}"
echo 'Configured: Fish + Tide, Fastfetch, fzf, Yazi, Lazygit, delta, zoxide, tealdeer, tmux, and Batcomputer Konsole.'
echo "Rollback: ./scripts/restore.sh '$BATCOMPUTER_BACKUP_DIR'"
echo 'Open a new Konsole window; existing Konsole sessions need restarting to load the profile and font.'
echo 'Log out and back in once for system-wide font changes.'
echo 'Atuin remains disabled; fzf provides local Ctrl+R history search with no cloud or database migration.'
echo 'See docs/TERMINAL.md for keyboard shortcuts and commands.'
