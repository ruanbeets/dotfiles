# Batcomputer Dotfiles

Restrained charcoal, cool grey and cyan. A native KDE engineering workstation
with a fast terminal at its center. Breeze underneath; no global theme bundles,
shell framework, cosmetic daemon, hardware polling script or window manager swap.

**Screenshot:** placeholder — add a reviewed, redacted image to `screenshots/`.
Screenshots are ignored by default because they can contain private data.

## QUICK INSTALL

On an up-to-date CachyOS / Arch installation with KDE Plasma 6:

```bash
sudo pacman -S --needed git openssh
git clone git@github.com:ruanbeets/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run
./install.sh
```

SSH access to GitHub is needed for that clone URL. A public repository can also
be cloned over HTTPS. Run the installer **as your ordinary desktop user**,
preferably inside Plasma. Only package installation uses sudo. Read the scripts
first; installation is interactive and does not refresh databases separately or
perform a system upgrade. If package downloads fail because mirrors are stale,
perform your normal full system update before trying again.

Open a new Konsole window afterward. Log out and back in once for fonts, icons,
cursor and application chrome to become consistent across already-running apps.

## Included components

| Component | Configuration |
|---|---|
| KDE | Batcomputer color scheme; Noto Sans UI; Breeze Dark icons; Breeze cursor/decoration; short native animations |
| Konsole | Batcomputer profile, JetBrainsMono Nerd Font 10.5 pt, opaque `#080B0D`, 20,000 lines, modest margins |
| fish | Native two-line prompt, Git branch/tracked edits, failure status, SSH-only host; no automatic greeting |
| fzf | Matching cyan selection, history/file/directory bindings |
| zoxide | `z` and `zi`, leaving `cd` unchanged |
| Fastfetch | Compact CachyOS logo and system summary through `sysinfo` |
| btop / nvtop | Matching btop theme; stock nvtop for reliable GPU details |
| lazygit | Matching borders and selection, restrained author colors |
| KVitals | Refines an existing top-panel widget without importing layout IDs |

Palette: background `#080B0D`, surfaces `#101519`, normal text `#C7CED1`,
secondary text `#829199`, accent `#36CFE0`, selection `#245563`. Muted semantic
red, amber and green remain available for errors, warnings and success.
The wallpaper is preserved and is **not distributed** in this repository.

The installer does not change login shell, Git identity, credentials, global
shortcuts, virtual desktops, display geometry, drivers, services or development
environments. Konsole explicitly starts fish even if another login shell is set.
It does not create future lab/project infrastructure.

## Terminal workflow

| Keys / command | Action |
|---|---|
| Ctrl+Alt+T | Open Konsole (standard CachyOS binding) |
| Ctrl+Shift+T / Ctrl+Shift+W | New tab / close current session |
| Shift+Right / Shift+Left | Next / previous tab |
| Ctrl+( / Ctrl+) | Left/right / top/bottom split |
| Ctrl+Shift+F | Search terminal output |
| Ctrl+Shift+M | Toggle menubar |
| Ctrl+R | fzf history search |
| Ctrl+T | Insert selected file paths |
| Alt+C | fzf directory selection |
| z / zi | Directory jump / interactive jump |
| sysinfo / monitor / gpu | Fastfetch / btop / one-shot NVIDIA summary |
| lazygit / nvtop | Git interface / GPU monitoring |

Konsole split navigation and any keyboard-layout-specific conflicts can be
adjusted in **Settings → Configure Keyboard Shortcuts**, searching for “view”.
This repository preserves existing application/global shortcuts.

Abbreviations: `g`, `gs`, `ga`, `gc`, `gp`, `gl`, `c`, `ll`, `la`, `lg`.
They expand visibly before execution. Core commands (`rm`, `cp`, `mv`, `sudo`,
`cd`, `ls`) are not replaced. Native fish autosuggestions and syntax highlighting
remain enabled. Git prompt `*` means unstaged tracked edits; `+` means staged
changes. It intentionally does not enumerate untracked files or contact remotes.
In a very large repository, disable dirty checks with
`set -g __fish_git_prompt_showdirtystate 0` in `~/.config/fish/local.fish`.

CachyOS's Pure prompt is overridden by two empty user `conf.d` files; its package
stays installed. The broad CachyOS alias bundle is no longer sourced. Other user
files are preserved. `local.fish` is an optional untracked local override.

## Packages

[`packages.txt`](packages.txt) is the complete requested package list. All are
available in official Arch/CachyOS repositories and installed with
`pacman -S --needed`. KDE itself is a prerequisite, not a replacement performed
by this installer. JetBrains Nerd Font occupies roughly 232 MiB on disk but does
not create a resident process. Fonts/icons are not vendored here.

Yazi is deliberately omitted: Dolphin remains the primary file manager.
Hyperfine is available for benchmarks. Tealdeer's page cache is downloaded only
when you request `tldr --update`. NVTop uses its supported default interface;
there is no custom GPU polling service or driver change.

## Updating and reinstalling

Edit this repository, review the diff, then run `./install.sh` again. Managed files
are copied rather than symlinked so applications cannot silently edit Git content.
To keep a GUI adjustment, port the particular portable setting back into the repo;
never copy your entire `~/.config` tree. Pull reviewed repository updates using
`git pull --ff-only`, then rerun the installer.

Options:

```bash
./install.sh --dry-run        # No writes, package installs or session changes
./install.sh --skip-packages  # Require all listed packages to already be installed
./install.sh --terminal-only  # Skip KDE appearance and panel changes
./kde/apply.sh                # Reapply only KDE appearance, with a new backup
```

XDG config/data/state directories are supported when they reside inside `$HOME`.
The installer is meant for one user, one invocation at a time. Package prompts
stay interactive; no AUR helper, network installer, systemd unit or recurring job
is created. Reruns preserve unrelated files and avoid duplicate PATH entries,
widgets and settings. Existing managed files are backed up before overwriting.

## Rollback

Every apply run prints its private backup directory under
`~/.local/state/batcomputer/backups/`. Its `manifest.tsv` records both previously
existing and previously absent files. Backups may contain personal settings;
keep them private and outside Git.

1. Save your work and **log out of Plasma**.
2. Switch to a text console with Ctrl+Alt+F3 and log in.
3. From the clone, run:

```bash
./scripts/restore.sh ~/.local/state/batcomputer/backups/PRINTED-BACKUP-DIRECTORY
```

The restore command moves current managed files into a separate rescue directory
before restoring originals. Files absent before installation are moved aside,
not deleted. Packages remain installed. Log back into Plasma. To undo multiple
apply runs, restore their backups in reverse chronological order; keep the first
installation backup to return to the original configuration.

For terminal-only rollback, exit Konsole/fish and restore the `fish`, `fastfetch`,
`btop`, `lazygit`, `konsole` and `konsolerc` entries from the first backup. For each
entry marked absent, move the newly installed file aside. Restoring the entire
backup with the provided script is less error-prone.

## KDE caveats and manual steps

See [`kde/README.md`](kde/README.md) for the short panel/KVitals checklist,
wallpaper restoration and appearance settings. A fresh installation requires
that manual panel setup because generated Plasma IDs and sensor identifiers
are intentionally not tracked. The majority of the appearance and the entire
terminal setup are reproduced by the installer.

Useful upstream references: [Plasma scripting](https://develop.kde.org/docs/plasma/scripting/api/),
[Konsole shortcuts](https://docs.kde.org/trunk_kf6/en/konsole/konsole/commandreference.html),
[fish](https://fishshell.com/docs/current/), and
[lazygit configuration](https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md).
