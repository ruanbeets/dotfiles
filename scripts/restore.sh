#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo 'Run as your desktop user.' >&2; exit 1; }
[[ $# == 1 ]] || { echo 'Usage: ./scripts/restore.sh BACKUP_DIRECTORY'; exit 2; }
backup=$(realpath -- "$1")
[[ -f $backup/manifest.tsv ]] || { echo 'Not an installer backup (manifest.tsv missing).' >&2; exit 1; }
# Run from a text console after logging out of Plasma so apps cannot rewrite files.
if pgrep -u "$UID" -x plasmashell >/dev/null; then
    echo 'Log out of Plasma, switch to a text console (Ctrl+Alt+F3), log in, then run restore.' >&2
    exit 1
fi
umask 077
rescue=$(mktemp -d "${backup}-before-restore-XXXX")
while IFS=$'\t' read -r state rel; do
    [[ $state == present || $state == absent ]] || exit 1
    [[ -n $rel && $rel != /* && /$rel/ != */../* ]] || exit 1
    [[ $state != present || -e $backup/files/$rel || -L $backup/files/$rel ]] || {
        echo "Missing backup data: $rel" >&2; exit 1;
    }
done < "$backup/manifest.tsv"
while IFS=$'\t' read -r state rel; do
    target=$HOME/$rel
    if [[ -e $target || -L $target ]]; then
        [[ ! -d $target || -L $target ]] || { echo "Refusing to move directory: $target" >&2; exit 1; }
        mkdir -p "$rescue/$(dirname "$rel")"
        mv -- "$target" "$rescue/$rel"
    fi
    if [[ $state == present ]]; then
        mkdir -p "$(dirname "$target")"
        cp -a -- "$backup/files/$rel" "$target"
    fi
done < "$backup/manifest.tsv"
echo "Restored. Replaced files were preserved in: $rescue"
echo 'Packages remain installed. Log back into Plasma.'
