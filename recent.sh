#!/usr/bin/env bash
# recent — list files modified in the last N minutes/hours/days
set -euo pipefail
ROOT="${1:-.}"
AGE="${2:--1day}" # default: last 1 day
echo "[*] Showing files in $ROOT modified since $AGE"
find "$ROOT" -type f -newermt "$(date -d "$AGE" '+%Y-%m-%d %H:%M:%S')" -print | sort
