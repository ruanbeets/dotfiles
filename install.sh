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
[[ $EUID -ne 0 ]] || { echo 'Run as your normal desktop user; sudo is used only for pacman.' >&2; exit 1; }
source /etc/os-release
[[ ${ID:-} == arch || ${ID:-} == cachyos || " ${ID_LIKE:-} " == *' arch '* ]] || {
    echo 'This installer requires Arch / CachyOS with KDE Plasma 6.' >&2; exit 1;
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
    echo 'Would back up and copy fish, Fastfetch, btop, lazygit, and Konsole files.'
    echo 'Would select Batcomputer as the default Konsole profile.'
    if ! $terminal_only; then echo 'Would apply KDE colors/fonts/icons/cursor and refine an existing top-panel KVitals widget.'; fi
    echo 'No changes made.'
    exit 0
fi
if $skip_packages; then
    if ((${#missing[@]})); then echo 'Install missing packages before using --skip-packages.' >&2; exit 1; fi
elif ((${#missing[@]})); then
    # Intentionally no database-only refresh (-Sy), no unattended system upgrade.
    sudo pacman -S --needed "${packages[@]}"
fi
for command in fish kwriteconfig6 kreadconfig6; do
    command -v "$command" >/dev/null || { echo "Missing KDE prerequisite: $command" >&2; exit 1; }
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
write_setting konsolerc 'Desktop Entry' DefaultProfile Batcomputer.profile
write_setting konsolerc TabBar TabBarVisibility ShowTabBarWhenNeeded
write_setting konsolerc TabBar ExpandTabWidth false
write_setting konsolerc TabBar NewTabButton true
write_setting konsolerc SplitView SplitViewVisibility ShowSplitHeaderWhenNeeded
write_setting konsolerc 'MainWindow' MenuBar Disabled
backup_file "$CONFIG_HOME/konsolerc"
kwriteconfig6 --file "$CONFIG_HOME/konsolerc" --group MainWindow --group 'Toolbar mainToolBar' --key Visible Disabled
kwriteconfig6 --file "$CONFIG_HOME/konsolerc" --group MainWindow --group 'Toolbar sessionToolbar' --key Visible Disabled
if ! $terminal_only; then bash "$ROOT/kde/apply.sh"; fi
echo
echo "Installed this run: ${missing[*]:-(none)}"
echo 'Configured: fish, fzf, zoxide, Fastfetch, btop, lazygit, and Batcomputer Konsole.'
echo "Rollback: ./scripts/restore.sh '$BATCOMPUTER_BACKUP_DIR'"
echo 'Open a new Konsole window. Log out and back in for consistent fonts/icons/cursors in all applications.'
echo 'Manual steps and wallpaper/panel caveats: kde/README.md'
