#!/usr/bin/env bash
#
# compress.sh — Universal compressor (extension flags + sane defaults)
# Usage:
#   ./compress.sh -tar.gz /path/to/source [-o /path/to/output_dir]
#   ./compress.sh -zip myfolder
#   ./compress.sh --install
#
# Notes:
#   - Output goes to the current directory unless -o is provided (as a directory).
#   - Type is chosen by a flag: -tar.gz | -tar.bz2 | -tar.xz | -tar.zst | -zip | -7z | -rar
#   - RAR creation requires 'rar' (not just unrar). If not available, we’ll warn.
#   - Easily extend types and package presets below.

set -euo pipefail

# ====== CONFIG: Add/adjust packages here ======
PKG_LIST_LINUX=(
  tar gzip bzip2 xz-utils zstd zip unzip p7zip-full  unrar-free  lz4
#add more here rar 
)
PKG_LIST_WINDOWS=(
  tar gzip bzip2 xz zstd zip p7zip 
)

# Minimal, safe default excludes for zip on directories (customize as you wish)
ZIP_DEFAULT_EXCLUDES=(
  "*/.DS_Store"
  "__MACOSX/*"
  "*.swp"
  "*.swo"
  "*.tmp"
  "*.bak"
  ".git/*"
  ".svn/*"
  ".hg/*"
  ".idea/*"
  ".vscode/*"
)

# ====== UTILS ======
usage() {
  cat <<EOF
Usage:
  $0 -tar.gz|-tar.bz2|-tar.xz|-tar.zst|-zip|-7z|-rar SOURCE [-o OUTPUT_DIR]
  $0 --install

Examples:
  $0 -tar.gz ./mydir
  $0 -zip ./file.txt -o /tmp/output
  $0 --install

Notes:
  - OUTPUT_DIR is a directory; the archive filename is derived from SOURCE.
  - Default output directory is the current working directory.
EOF
  exit 1
}

install_tools() {
  echo "[*] Installing compression tools..."
  if command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y "${PKG_LIST_LINUX[@]}"
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y "${PKG_LIST_LINUX[@]}"
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm "${PKG_LIST_LINUX[@]}"
  elif command -v choco >/dev/null 2>&1; then
    choco install -y "${PKG_LIST_WINDOWS[@]}"
  else
    echo "[!] Package manager not detected. Install tools manually:"
    echo "    ${PKG_LIST_LINUX[*]}"
    exit 1
  fi
  echo "[+] Installation complete."
  exit 0
}

need() {
  # need cmd [friendly-name]
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[!] Missing tool: ${2:-$1}. Try: $0 --install" >&2
    exit 1
  fi
}

is_dir() {
  [[ -d "$1" ]]
}

derive_name() {
  # Given SOURCE path, produce base name without trailing slash
  local src="$1"
  src="${src%/}"
  basename "$src"
}

ensure_outdir() {
  local outdir="$1"
  mkdir -p "$outdir"
}

# ====== COMPRESSION IMPLS ======
do_tar_variant() {
  # do_tar_variant compressor_flag src outdir
  local flag="$1" src="$2" outdir="$3"
  need tar tar
  local name ext tar_args
  name="$(derive_name "$src")"

  case "$flag" in
    -tar.gz)  need gzip gzip; ext="tar.gz"; tar_args=("czf");;
    -tar.bz2) need bzip2 bzip2; ext="tar.bz2"; tar_args=("cjf");;
    -tar.xz)  need xz xz; ext="tar.xz"; tar_args=("cJf");;
    -tar.zst) need zstd zstd; ext="tar.zst"; tar_args=("cf"); tar_args=("--zstd" "${tar_args[@]}");;
    *) echo "[!] Unknown tar variant: $flag"; exit 1;;
  esac

  ensure_outdir "$outdir"
  local outfile="$outdir/$name.$ext"
  tar "${tar_args[@]}" "$outfile" -C "$(dirname "$src")" "$(basename "$src")"
  echo "[+] Created: $outfile"
}

do_zip() {
  local src="$1" outdir="$2"
  need zip zip
  local name outfile
  name="$(derive_name "$src")"
  ensure_outdir "$outdir"
  outfile="$outdir/$name.zip"

  if is_dir "$src"; then
    # Build exclude args
    local ex=()
    for pat in "${ZIP_DEFAULT_EXCLUDES[@]}"; do
      ex+=(-x "$pat")
    done
    ( cd "$(dirname "$src")" && zip -rq "$outfile" "$(basename "$src")" "${ex[@]}" )
  else
    ( cd "$(dirname "$src")" && zip -q  "$outfile" "$(basename "$src")" )
  fi

  echo "[+] Created: $outfile"
}

do_7z() {
  local src="$1" outdir="$2"
  need 7z "p7zip (7z)"
  local name outfile
  name="$(derive_name "$src")"
  ensure_outdir "$outdir"
  outfile="$outdir/$name.7z"
  ( cd "$(dirname "$src")" && 7z a -bso0 -bsp0 -bse0 "$outfile" "$(basename "$src")" >/dev/null )
  echo "[+] Created: $outfile"
}

do_rar() {
  local src="$1" outdir="$2"
  if ! command -v rar >/dev/null 2>&1; then
    echo "[!] 'rar' (for creating RAR archives) not found. 'unrar' cannot create archives."
    echo "    Install 'rar' or choose -7z or -zip instead. Try: $0 --install"
    exit 1
  fi
  local name outfile
  name="$(derive_name "$src")"
  ensure_outdir "$outdir"
  outfile="$outdir/$name.rar"
  ( cd "$(dirname "$src")" && rar a -idq "$outfile" "$(basename "$src")" )
  echo "[+] Created: $outfile"
}

# ====== ARG PARSING ======
if [[ $# -eq 0 ]]; then
  usage
fi

TYPE=""
SRC=""
OUTDIR="$(pwd)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --install)
      install_tools
      ;;
    -tar.gz|-tar.bz2|-tar.xz|-tar.zst|-zip|-7z|-rar)
      TYPE="$1"
      shift
      ;;
    -o|--output)
      [[ $# -ge 2 ]] || { echo "[!] -o requires a path"; exit 1; }
      OUTDIR="$2"
      shift 2
      ;;
    -*)
      echo "[!] Unknown flag: $1"
      usage
      ;;
    *)
      # First non-flag is SOURCE
      if [[ -z "${SRC:-}" ]]; then
        SRC="$1"
        shift
      else
        echo "[!] Unexpected extra argument: $1"
        usage
      fi
      ;;
  esac
done

[[ -n "$TYPE" ]] || { echo "[!] Compression type flag is required (e.g., -tar.gz, -zip)"; usage; }
[[ -n "$SRC"  ]] || { echo "[!] SOURCE path is required"; usage; }
[[ -e "$SRC"  ]] || { echo "[!] SOURCE not found: $SRC"; exit 1; }

# ====== DISPATCH ======
case "$TYPE" in
  -tar.gz|-tar.bz2|-tar.xz|-tar.zst) do_tar_variant "$TYPE" "$SRC" "$OUTDIR" ;;
  -zip)  do_zip "$SRC" "$OUTDIR" ;;
  -7z)   do_7z "$SRC" "$OUTDIR" ;;
  -rar)  do_rar "$SRC" "$OUTDIR" ;;
  *)     echo "[!] Unsupported type: $TYPE"; exit 1 ;;
esac
