#!/usr/bin/env bash
#
# mesh-tools-installer.sh — Drop your mesh rituals onto any node
# Usage:
#   ./mesh-tools-installer.sh [--with-deps] [--prefix /custom/bin]
#
#   --with-deps   Run each tool's --install after copying (if supported)
#   --prefix DIR  Install scripts into DIR (default: /usr/local/bin)
#
# Author: Jake's lalab edition

set -euo pipefail

PREFIX="/usr/local/bin"
WITH_DEPS=false

# ====== LIST OF TOOLS ======
# Add your scripts here — local paths relative to this installer

TOOLS=(
  "./extract.sh"
  "./compress.sh"
  "./findit.sh"
  "./mkcd.sh"
  "./cleanup.sh"
  "./recent.sh"
  "./grepit.sh"
  "./quickserve.sh"
  "./syswatch.sh"
  "./backup.sh"
  "./syncdir.sh"
  "./pushit.sh"
)

usage() {
  echo "Usage: $0 [--with-deps] [--prefix /custom/bin]"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-deps) WITH_DEPS=true; shift ;;
    --prefix) PREFIX="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "[!] Unknown arg: $1"; usage ;;
  esac
done

echo "[*] Installing mesh tools to: $PREFIX"
sudo mkdir -p "$PREFIX"

for tool in "${TOOLS[@]}"; do
  if [[ ! -f "$tool" ]]; then
    echo "[!] Tool not found: $tool"
    exit 1
  fi
  # Strip .sh for cleaner command name
  name="$(basename "$tool" .sh)"
  sudo cp "$tool" "$PREFIX/$name"
  sudo chmod +x "$PREFIX/$name"
  echo "[+] Installed: $name"
  if $WITH_DEPS; then
    echo "[*] Checking for --install support in: $name"
    if grep -q -- "--install" "$tool"; then
      sudo "$PREFIX/$name" --install || true
    else
      echo "    (no --install option for $name)"
    fi
  fi
done

echo "[✓] Mesh tools installed successfully."


