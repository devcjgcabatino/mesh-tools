#!/usr/bin/env bash
# backup — create a timestamped archive of a file or directory
set -euo pipefail

SRC="${1:-}"
DEST_DIR="${2:-$HOME/backups}"

if [[ -z "$SRC" ]]; then
    echo "Usage: backup <source_path> [destination_dir]"
    exit 1
fi

mkdir -p "$DEST_DIR"
BASENAME="$(basename "$SRC")"
STAMP="$(date +%Y%m%d_%H%M%S)"
OUTFILE="$DEST_DIR/${BASENAME}_$STAMP.tar.gz"

tar czf "$OUTFILE" -C "$(dirname "$SRC")" "$BASENAME"
echo "[+] Backup created: $OUTFILE"
