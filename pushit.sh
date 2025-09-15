#!/usr/bin/env bash
# pushit — send a file to a remote host via scp
set -euo pipefail

CONFIG_FILE="$HOME/.pushit.conf"

if [[ $# -lt 1 ]]; then
    echo "Usage: pushit <file> [user@host:/path]"
    exit 1
fi

FILE="$1"
DEST="${2:-}"

if [[ -z "$DEST" ]]; then
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        if [[ -z "${LAST_DEST:-}" ]]; then
            echo "[!] No saved destination. Please specify one."
            exit 1
        fi
        DEST="$LAST_DEST"
    else
        echo "[!] No destination provided and no saved destination found."
        exit 1
    fi
else
    echo "LAST_DEST=\"$DEST\"" > "$CONFIG_FILE"
    echo "[*] Saved destination: $DEST"
fi

scp "$FILE" "$DEST"
echo "[✓] File pushed to $DEST"
