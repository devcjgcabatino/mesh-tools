#!/usr/bin/env bash
# syncdir — sync two directories with rsync
set -euo pipefail

SRC="${1:-}"
DEST="${2:-}"

if [[ -z "$SRC" || -z "$DEST" ]]; then
    echo "Usage: syncdir <source_dir> <destination_dir_or_user@host:/path>"
    exit 1
fi

echo "[*] Syncing $SRC -> $DEST"
rsync -avh --progress --delete "$SRC" "$DEST"
echo "[✓] Sync complete."
