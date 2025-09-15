#!/usr/bin/env bash
#
# extract.sh — Universal archive extractor with auto-type detection
# Usage:
#   ./extract.sh file.tar.gz
#   ./extract.sh -o /path/to/output file.zip
#   ./extract.sh --install
#
# Supports: tar, gz, bz2, xz, zip, rar, 7z, iso, lzma, zst, cab, arj, lha, etc.

set -e

# ====== CONFIG: Add more packages here if needed ======
PKG_LIST_LINUX=(
    unzip p7zip-full  unrar-free tar gzip bzip2 xz-utils lzma lzop zstd cabextract arj lhasa
#    add more here such as rar
)
PKG_LIST_WINDOWS=(
    p7zip unzip tar gzip bzip2 xz zstd cabextract
)

# ====== FUNCTIONS ======

install_tools() {
    echo "[*] Installing extraction tools..."
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
        echo "[!] Package manager not detected. Install tools manually."
        exit 1
    fi
    echo "[+] Installation complete."
    exit 0
}

extract_file() {
    local file="$1"
    local outdir="$2"

    mkdir -p "$outdir"

    case "$file" in
        *.tar.bz2|*.tbz2)   tar xjf "$file" -C "$outdir" ;;
        *.tar.gz|*.tgz)     tar xzf "$file" -C "$outdir" ;;
        *.tar.xz)           tar xJf "$file" -C "$outdir" ;;
        *.tar.zst)          tar --zstd -xf "$file" -C "$outdir" ;;
        *.tar.lzma)         tar --lzma -xf "$file" -C "$outdir" ;;
        *.tar)              tar xf "$file" -C "$outdir" ;;
        *.gz)               gunzip -c "$file" > "$outdir/$(basename "${file%.gz}")" ;;
        *.bz2)              bunzip2 -c "$file" > "$outdir/$(basename "${file%.bz2}")" ;;
        *.xz)               unxz -c "$file" > "$outdir/$(basename "${file%.xz}")" ;;
        *.zip)              unzip -q "$file" -d "$outdir" ;;
        *.rar)              unrar x -o+ "$file" "$outdir" ;;
        *.7z)               7z x "$file" -o"$outdir" ;;
        *.iso)              7z x "$file" -o"$outdir" ;;
        *.lzma)             unlzma -c "$file" > "$outdir/$(basename "${file%.lzma}")" ;;
        *.zst)              zstd -d "$file" -o "$outdir/$(basename "${file%.zst}")" ;;
        *.cab)              cabextract -d "$outdir" "$file" ;;
        *.arj)              arj x "$file" "$outdir" ;;
        *.lha|*.lzh)        lha x "$file" "$outdir" ;;
        *)                  echo "[!] Unknown file type: $file"; exit 1 ;;
    esac

    echo "[+] Extracted to: $outdir"
}

# ====== MAIN ======

if [[ "$1" == "--install" ]]; then
    install_tools
fi

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 [-o output_dir] file"
    exit 1
fi

OUTPUT_DIR=""
FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        *)
            FILE="$1"
            shift
            ;;
    esac
done

if [[ -z "$FILE" ]]; then
    echo "[!] No file specified."
    exit 1
fi

if [[ ! -f "$FILE" ]]; then
    echo "[!] File not found: $FILE"
    exit 1
fi

if [[ -z "$OUTPUT_DIR" ]]; then
    BASENAME="$(basename "$FILE")"
    OUTPUT_DIR="${BASENAME%.*}"
    # Handle double extensions like .tar.gz
    OUTPUT_DIR="${OUTPUT_DIR%.*}"
fi

extract_file "$FILE" "$OUTPUT_DIR"
