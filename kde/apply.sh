#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/scripts/common.sh"
[[ $EUID -ne 0 ]] || { echo 'Run as your desktop user.' >&2; exit 1; }
init_paths
for command in kwriteconfig6 kreadconfig6 plasma-apply-colorscheme; do
    command -v "$command" >/dev/null || { echo "Missing: $command" >&2; exit 1; }
done
init_backup
deploy_file "$ROOT/kde/Batcomputer.colors" "$DATA_HOME/color-schemes/Batcomputer.colors"
# KDE's color tool may also export colors to GTK settings. Back those up too.
for file in kdeglobals kwinrc kcminputrc plasmarc breezerc gtk-3.0/settings.ini gtk-4.0/settings.ini xsettingsd/xsettingsd.conf; do
    prepare_config "$CONFIG_HOME/$file"
done
prepare_config "$HOME/.gtkrc-2.0"
write_setting kdeglobals General AccentColor '138,98,197'
for key in font menuFont toolBarFont; do
    write_setting kdeglobals General "$key" 'Noto Sans,10,-1,5,400,0,0,0,0,0'
done
write_setting kdeglobals General smallestReadableFont 'Noto Sans,9,-1,5,400,0,0,0,0,0'
write_setting kdeglobals General fixed 'JetBrainsMono Nerd Font,10.5,-1,5,400,0,0,0,0,0'
write_setting kdeglobals WM activeFont 'Noto Sans,10,-1,5,500,0,0,0,0,0'
write_setting kdeglobals Icons Theme breeze-dark
write_setting kdeglobals KDE widgetStyle Breeze
write_setting kdeglobals KDE AnimationDurationFactor 0.5
write_setting kcminputrc Mouse cursorTheme breeze_cursors
write_setting kcminputrc Mouse cursorSize 24
write_setting plasmarc Theme name default
# Use the stock Breeze decoration; no global theme replacement or layout reset.
write_setting kwinrc org.kde.kdecoration2 library org.kde.breeze
write_setting kwinrc org.kde.kdecoration2 theme Breeze
write_setting kwinrc org.kde.kdecoration2 BorderSize None
if [[ ${XDG_CURRENT_DESKTOP:-} == *KDE* ]] && qdbus6 org.kde.plasmashell /PlasmaShell >/dev/null 2>&1; then
    # Plasma skips reapplying a scheme when its name is already current. If
    # the installed Batcomputer file changed, briefly select BreezeDark so
    # the same-named palette is reloaded into the live session.
    active_accent=$(kreadconfig6 --file kdeglobals --group Colors:View --key ForegroundActive)
    if [[ $active_accent != '138,98,197' ]]; then
        plasma-apply-colorscheme BreezeDark
    fi
    plasma-apply-colorscheme Batcomputer
    plasma-apply-cursortheme --size 24 breeze_cursors
    qdbus6 org.kde.KWin /KWin reconfigure
    backup_file "$CONFIG_HOME/plasma-org.kde.plasma.desktop-appletsrc"
    backup_file "$CONFIG_HOME/plasmashellrc"
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat "$ROOT/kde/panel.js")"
else
    # Merge only palette groups offline; never import a machine's whole kdeglobals.
    group=''
    while IFS= read -r line; do
        if [[ $line =~ ^\[(.*)\]$ ]]; then group=${BASH_REMATCH[1]}; continue; fi
        [[ $line == *=* ]] || continue
        case "$group" in
            Colors:*|ColorEffects:*|WM) write_setting kdeglobals "$group" "${line%%=*}" "${line#*=}" ;;
        esac
    done < "$ROOT/kde/Batcomputer.colors"
    write_setting kdeglobals General ColorScheme Batcomputer
    echo 'KDE session unavailable: palette saved; run kde/apply.sh inside Plasma for live application and panel styling.'
fi
echo 'KDE appearance configured. Wallpaper, monitors, shortcuts and virtual desktops preserved.'
