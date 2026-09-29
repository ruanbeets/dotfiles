# Batcomputer Dotfiles

Reproducible CachyOS / Arch KDE settings for a dark research workstation. The
terminal palette follows the installed black, violet, magenta, and yellow
wallpaper. KDE Plasma, Wayland, Konsole, and Fish remain the desktop stack.

## QUICK INSTALL

On a CachyOS / Arch KDE installation:

```bash
sudo pacman -S --needed git openssh
git clone git@github.com:ruanbeets/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Run the installer as your normal desktop user. It asks `sudo` only when pacman
needs to install missing packages. It does not refresh package databases alone,
upgrade the system, switch login shells, start services, or install AUR packages.
`./install.sh --dry-run` reviews the package and configuration actions first.

## Batcomputer Terminal

| Tool | Role |
|---|---|
| Konsole | Primary terminal with the Batcomputer profile and truecolor palette |
| Fish + Fisher + Tide v6 | Fast Powerlevel10k-inspired segmented prompt, with active virtualenv, Git state, errors, jobs, remote context, and long command duration |
| Fastfetch | Automatic compact machine dashboard in standalone interactive Fish sessions |
| tmux + TPM | Optional persistent sessions, splits, and a custom status line |
| Yazi | Terminal file manager; `y` returns to the directory selected on exit |
| Lazygit | Git interface with Nerd Font v3 icons; `lg` opens it |
| fzf | Fish history, file, and directory search with palette-matched previews |
| zoxide | Fast `z` / `zi` directory jumps while regular `cd` remains available |
| git-delta | Readable Git diffs through the normal Git pager |
| tealdeer | Fast command examples through `tldr <command>` |

The default palette uses `#030405` black, `#0F0716` surfaces, deep violet,
`#D72AC0` magenta, `#F6E72B` signal yellow, and `#E8E6EA` foreground. Semantic
red, green, blue, and cyan remain available for status and terminal output.
JetBrainsMono Nerd Font is used in Konsole; terminal applications inherit it.

Fastfetch runs once in a standalone interactive Fish shell. Nested Fish and
tmux panes skip the banner. Atuin is not enabled: fzf already provides the
requested local Ctrl+R history search, and no command history is uploaded.

See [docs/TERMINAL.md](docs/TERMINAL.md) for shortcuts, shell commands, and tmux
workflows. See [kde/README.md](kde/README.md) for the KDE appearance details.

## Installer and rollback

`install.sh` is safe to rerun. It backs up every existing managed file under
`~/.local/state/batcomputer/backups/` before replacing it. It also records
machine package state there. Fish plugins come from
`config/fish/fish_plugins`; tmux plugins come from the TPM declarations in
`config/tmux/tmux.conf`. Their checkouts and shell history are not tracked.

The installer copies managed files, leaving the repository independent of GUI
application edits. Git reads the tracked `config/git/config` through its native
XDG global-config location, leaving any legacy `~/.gitconfig` intact. It does
not track shell history, Atuin databases, tmux
resurrect state, credentials, caches, machine IDs, or browser data.

Every install prints its backup path. To restore it, exit Konsole and run:

```bash
./scripts/restore.sh ~/.local/state/batcomputer/backups/PRINTED-BACKUP-DIRECTORY
```

The restore script saves the current managed files separately before restoring
the backup. Packages remain installed. Existing Konsole windows need a restart
to load profile changes; log out once for system-wide font changes.

Options: `--dry-run`, `--skip-packages` (require all packages already present),
and `--terminal-only` (skip KDE appearance changes).
