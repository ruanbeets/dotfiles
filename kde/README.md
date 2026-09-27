# KDE appearance and the portable boundary

`apply.sh` uses native KConfig tools and Plasma's one-shot scripting interface.
It applies the repository's color scheme, Noto Sans UI fonts, JetBrains Mono
fixed-width font, Breeze Dark icons, 24 px Breeze cursor, Breeze decoration with
no extra border, and animation duration factor 0.5. No custom effect is installed.
The standard Breeze Plasma style follows the color scheme.

Existing wallpaper, monitor arrangement, panel height, task launchers, tray,
audio/network controls, clock, desktop shortcuts and virtual desktops are kept.
Dolphin inherits the global appearance. Its native terminal panel is F4 and hidden
files are toggled with Alt+.; no Dolphin plugin is required for this rice.

## Current workstation

The one-shot `panel.js` only acts if there is exactly one top panel containing
one KVitals widget. It filters the **existing** pinned sensor identifiers to CPU
usage/temperature, GPU usage/temperature, RAM percentage and network throughput.
It removes that panel's standalone disk-activity widget and styles KVitals with
14 px JetBrains Mono, cyan labels and cool grey values. It never invents GPU IDs,
changes the update interval, creates widgets or modifies the KVitals source.
It preserves the existing panel dimensions and widget order.

## Fresh-install panel checklist

1. Right-click panel → **Enter Edit Mode**. Move it to the top, use about **40–42 px**
   height, full width, nonfloating. Use Adaptive opacity (or Opaque if preferred).
2. Keep Application Launcher and Icons-only Task Manager on the left. Pin Konsole,
   Dolphin and your browser. Keep task-manager spacing compact. Leave the task
   manager flexible so the center remains open.
3. Add **KVitals** only from its upstream/KDE widget listing after checking Plasma
   compatibility. The existing workstation uses version 3.2.1 from
   [upstream](https://github.com/yassine20011/kvitals). This installer neither
   downloads arbitrary widget code nor assumes an official-repository package.
   Native System Monitor widgets are the fallback if KVitals is unavailable.
4. In KVitals settings, pin CPU usage + temperature, your actual GPU usage +
   temperature, RAM percentage, network download + upload. Confirm the sensor
   readings. Place it immediately before the tray and clock.
5. Keep system tray, audio/network controls and clock on the right. Unpin uptime,
   RAM temperature and system temperature; remove the separate disk indicator.
6. Run `./kde/apply.sh` to apply typography/colors to that existing widget.

If automatic refinement reports an ambiguous panel layout, use KVitals settings:
General → font **JetBrainsMono Nerd Font**, **14 px**, display **Text**, merge
related metrics, separators enabled. Colors: values `#C7CED1`, labels `#36CFE0`,
icons/accent `#36CFE0`. Keep the working sensor bindings and refresh interval.

## Wallpaper and remaining GUI settings

The current black geometric wallpaper is untouched. Keep your own copy outside
Git. On a fresh system, right-click desktop → **Desktop and Wallpaper Settings**
and select it for each display. Monitor placement/scaling stays in System Settings
→ **Display & Monitor → Display Configuration** and is never imported here.

If a running application still shows its old font/theme, close and reopen it;
log out/in once for a fully consistent session. Konsole: **Settings → Manage
Profiles → Batcomputer → Set as Default** is the fallback if an already-running
Konsole process retains its previous default. **Settings → Toolbars Shown** can
hide either toolbar; **Ctrl+Shift+M** restores the menu at any time.

KRunner shortcuts and native effects are left alone. If desired, enable stock
Blur in **System Settings → Window Management → Desktop Effects**; the opaque
terminal intentionally does not need blur. NVTop keeps its upstream UI colors.

## Verification and rollback

After applying, inspect System Settings → **Colors & Themes** (Colors, Icons,
Cursors, Window Decorations) and **Text & Fonts → Fonts**. The scheme is named
**Batcomputer**. Open a new Konsole and Dolphin window; verify selection contrast,
readability and intact telemetry.

See the root README for rollback. Live KDE and applications may overwrite restored
settings if they are still running, so restore from a text console after logout.
No package removal or service changes are part of rollback.
