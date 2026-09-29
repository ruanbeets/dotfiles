# Batcomputer Terminal

## Open and navigate

| Key or command | Action |
|---|---|
| Ctrl+Alt+T | Open Konsole |
| Ctrl+Shift+T / Ctrl+Shift+W | New tab / close tab |
| Shift+Right / Shift+Left | Next / previous tab |
| Ctrl+R | Search Fish history with fzf |
| Ctrl+T | Find and insert a file path with a bat preview |
| Alt+C | Find and enter a directory with an eza tree preview |
| `z <part-of-path>` | Jump to a frequently used directory |
| `zi` | Pick a directory interactively |
| `y` | Browse files in Yazi and return to its final directory |

`cd` keeps its normal Fish behavior. The `ll` and `la` abbreviations use eza
with Nerd Font icons. Fish abbreviations expand visibly before execution.

## Prompt and Git

Tide shows the current directory and Git branch/state on the first line, then a
colored command marker below. A red marker reports a failed last command. The
right side appears only when useful: SSH/root context, active Python virtual
environment, background jobs, or a command that ran longer than five seconds.

| Abbreviation | Expands to |
|---|---|
| `g` / `gs` | `git` / `git status` |
| `ga` / `gc` / `gp` | `git add` / `git commit` / `git push` |
| `gl` | Decorated graph log |
| `lg` | Lazygit |
| `ff` / `bt` / `gpu` | Fastfetch / btop / nvtop |
| `c` | `clear` |

Git remains the canonical interface. Delta improves `git diff`, `git show`, and
`git log -p` through Git's configured pager.

## Konsole

The `Batcomputer` profile uses JetBrainsMono Nerd Font at 10.5 pt, 20,000 lines
of scrollback, subtle 97% opacity, a nonblinking cursor, and the Batcomputer
truecolor scheme. The scheme keeps red for errors, green for success, yellow
for warnings, and blue/cyan for secondary information while using Skeletor
violet with signal yellow as the main accents.

Konsole's standard tab, split, search, and menu shortcuts remain configurable
through **Settings → Configure Keyboard Shortcuts**. The installer hides the
menubar and shows tabs only when useful. Close and reopen Konsole after install
to load its profile and color scheme.

## tmux

Start tmux only when you want a persistent workspace:

```fish
tmux new -A -s research
```

The default prefix is Ctrl+B. `prefix + |` splits vertically and `prefix + -`
splits horizontally. Use prefix plus `h`, `j`, `k`, or `l` to move between
panes; prefix plus `H`, `J`, `K`, or `L` resizes them. Mouse selection and
scrolling are enabled. Copy mode uses vi keys: prefix + `[` to enter, `v` to
start selection, `y` to copy, and `q` to leave.

The status bar shows the session, windows, current pane directory, and time. It
does not poll hardware. TPM installs only `tmux-sensible` and `tmux-resurrect`.
Use prefix + Ctrl+S to save a session layout and prefix + Ctrl+R to restore it.
Resurrect state stays local and is never committed. It saves session layout but
does not launch saved applications when restoring.

## Truecolor and fonts

Konsole advertises its xterm 256-color terminal type and Fish exports
`COLORTERM=truecolor`. tmux uses `tmux-256color` and enables RGB passthrough for
Konsole clients. If a remote host renders icons as empty boxes, install or
select JetBrainsMono Nerd Font in that host's terminal emulator too; local
font files are not transmitted over SSH.

## Local history

Fish history stays in Fish's normal local history file, which is excluded from
Git. fzf handles Ctrl+R without a daemon or cloud account. Atuin is deliberately
not enabled; no Atuin account or sync configuration is created.
