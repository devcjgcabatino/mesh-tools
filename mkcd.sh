#!/usr/bin/env bash
# mkcd — create a directory and cd into it
set -euo pipefail
if [[ $# -eq 0 ]]; then
    echo "Usage: mkcd <directory>"
    exit 1
fi
mkdir -p "$1"
cd "$1" || exit
