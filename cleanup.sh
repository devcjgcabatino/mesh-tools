#!/usr/bin/env bash
# cleanup — find and optionally delete junk files
set -euo pipefail
TARGET="${1:-.}"
echo "[*] Scanning $TARGET for junk files..."
find "$TARGET" \( -name '*.tmp' -o -name '*.bak' -o -name '*.swp' -o -name '.DS_Store' -o -name '__MACOSX' \) -print
read -rp "Delete these files? [y/N]: " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
    find "$TARGET" \( -name '*.tmp' -o -name '*.bak' -o -name '*.swp' -o -name '.DS_Store' -o -name '__MACOSX' \) -delete
    echo "[+] Cleanup complete."
else
    echo "[*] Skipped deletion."
fi
