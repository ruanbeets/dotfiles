# Change record

## 2026-09-27 — Initial Batcomputer interface

- Added native Breeze-based charcoal/cyan colors, Noto Sans application fonts,
  JetBrains Mono Nerd Font terminals/telemetry, Breeze Dark icons and Breeze cursor.
- Added opaque Batcomputer Konsole profile with 20,000-line scrollback, compact
  padding, subdued semantic ANSI colors and native tabs/splits.
- Replaced the CachyOS shell bundle/Pure prompt with explicit native fish setup,
  preserving installed packages and unrelated user configuration.
- Added fzf history/file/directory bindings and palette; zoxide `z`/`zi` leave
  `cd` unchanged. Added visible abbreviations and `sysinfo`, `monitor`, `gpu`.
- Added compact on-demand Fastfetch and matching btop/lazygit styling.
- Refined existing KVitals sensor selection, typography and labels through a
  one-shot native Plasma API. Removed redundant disk-activity indicator.
- Preserved wallpaper, 42 px panel, working sensor identifiers, monitors,
  application launchers, global shortcuts and virtual desktops.
- Added a readable installer, private timestamped backups, reversible restore,
  package manifest, fresh-install manual checklist and screenshot placeholder.
- No new service, framework, AUR package, driver change or development stack.

New packages on the original workstation: `ttf-jetbrains-mono-nerd`, `zoxide`,
`nvtop`, `lazygit`, `hyperfine`. No package upgrades or removals were needed.

Validation: isolated-home dry-run/deployment/rerun/rollback tests, including
symlink safety and unrelated-file preservation; fish syntax, prompt failures,
pipeline failures, fzf bindings and zoxide loading; real KDE application and
20,000-line Konsole scrollback; visual desktop inspection; successful interactive
btop, nvtop and lazygit startup/exit checks. Source review excludes
secrets, histories, generated IDs, authentication and hardware display layouts.

Warm fish startup measured about **33 ms before / 15.5 ms after** on the original
workstation (read-only sandbox; 20 post-change runs). First prompt about **31 ms**
in the dotfiles Git repository. These are shell timings, not window-launch or
keystroke-latency measurements. No resident cosmetic process was added.

Toolbar visibility is stored in Qt window state, so the installer does not
pretend a portable KConfig key controls it. The current workstation's toolbars
were hidden using Konsole's native interface; the fresh-install two-click step
is documented in `kde/README.md`.
