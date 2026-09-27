#!/usr/bin/env bash
# Shared by the installer and the independently runnable KDE apply script.

init_paths() {
    CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
    DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
    STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}
    for path in "$CONFIG_HOME" "$DATA_HOME" "$STATE_HOME"; do
        case "$path" in "$HOME"/*) ;; *) echo "XDG directories must be inside HOME: $path" >&2; exit 1;; esac
        case "$path" in */../*|*/..) echo 'Parent traversal is not supported.' >&2; exit 1;; esac
    done
}

init_backup() {
    umask 077
    if [[ -z ${BATCOMPUTER_BACKUP_DIR:-} ]]; then
        mkdir -p "$STATE_HOME/batcomputer/backups"
        BATCOMPUTER_BACKUP_DIR=$(mktemp -d "$STATE_HOME/batcomputer/backups/$(date +%Y%m%d-%H%M%S)-XXXX")
        export BATCOMPUTER_BACKUP_DIR
    fi
    mkdir -p "$BATCOMPUTER_BACKUP_DIR/files"
    touch "$BATCOMPUTER_BACKUP_DIR/manifest.tsv"
    echo "Backup: $BATCOMPUTER_BACKUP_DIR"
}

backup_file() {
    local target=$1 rel
    [[ $target == "$HOME"/* ]] || { echo "Refusing backup outside HOME: $target" >&2; exit 1; }
    rel=${target#"$HOME"/}
    # Reject delimiters and traversal in the simple, human-readable manifest.
    [[ $rel != *$'\t'* && $rel != *$'\n'* && /$rel/ != */../* ]] || exit 1
    if cut -f2 "$BATCOMPUTER_BACKUP_DIR/manifest.tsv" | grep -Fxq -- "$rel"; then return; fi
    if [[ -e $target || -L $target ]]; then
        [[ ! -d $target || -L $target ]] || { echo "Expected a file: $target" >&2; exit 1; }
        mkdir -p "$BATCOMPUTER_BACKUP_DIR/files/$(dirname "$rel")"
        cp -a -- "$target" "$BATCOMPUTER_BACKUP_DIR/files/$rel"
        printf 'present\t%s\n' "$rel" >> "$BATCOMPUTER_BACKUP_DIR/manifest.tsv"
    else
        printf 'absent\t%s\n' "$rel" >> "$BATCOMPUTER_BACKUP_DIR/manifest.tsv"
    fi
}

deploy_file() {
    local source=$1 target=$2 tmp
    if [[ -f $target && ! -L $target ]] && cmp -s -- "$source" "$target"; then return; fi
    backup_file "$target"
    mkdir -p "$(dirname "$target")"
    tmp=$(mktemp "$(dirname "$target")/.batcomputer-XXXX")
    install -m 644 -- "$source" "$tmp"
    mv -fT -- "$tmp" "$target"
    printf 'Configured: %s\n' "$target"
}

write_setting() {
    local file=$1 group=$2 key=$3 value=$4
    backup_file "$CONFIG_HOME/$file"
    kwriteconfig6 --file "$CONFIG_HOME/$file" --group "$group" --key "$key" "$value"
}
