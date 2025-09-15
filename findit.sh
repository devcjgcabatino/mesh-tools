#!/usr/bin/env bash
#
# findit — Interactive find command helper with persistent default root path
# Author: Jakec

set -euo pipefail

CONFIG_FILE="$HOME/.findit.conf"
DEFAULT_ROOT="/home/$USER"

# ====== CONFIG HANDLING ======
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        # shellcheck disable=SC1090
        source "$CONFIG_FILE"
    fi
    # If config didn't set ROOT_PATH, fall back
    ROOT_PATH="${ROOT_PATH:-$DEFAULT_ROOT}"
}

save_config() {
    echo "ROOT_PATH=\"$ROOT_PATH\"" > "$CONFIG_FILE"
    echo "[+] Saved default root path to $CONFIG_FILE"
}

set_new_default() {
    read -rp "Enter new default root path: " newpath
    if [[ -n "$newpath" && -d "$newpath" ]]; then
        ROOT_PATH="$newpath"
        save_config
    else
        echo "[!] Invalid path. Keeping current default: $ROOT_PATH"
    fi
}

# ====== PROMPTS ======
prompt_root() {
    read -rp "Root path [$ROOT_PATH]: " var
    if [[ -z "$var" ]]; then
        echo "$ROOT_PATH"
    else
        echo "$var"
    fi
}

menu() {
    echo "Select find mode:"
    echo " 1) Find files by extension"
    echo " 2) Find files matching multiple path/name patterns"
    echo " 3) Find directories by name (case-insensitive)"
    echo " 4) Find files matching pattern, excluding paths"
    echo " 5) Find files by size range (with max depth)"
    echo " 6) Run a command for each matching file"
    echo " 7) Find files modified today and pass to single command"
    echo " 8) Find empty files or directories and delete"
    echo " 9) Change default root path"
    echo "10) Quit"
    echo
}

# ====== MAIN LOOP ======
load_config

while true; do
    menu
    read -rp "Enter choice [1-10]: " choice
    case "$choice" in
        1)
            root=$(prompt_root)
            read -rp "Extension (e.g. txt): " ext
            echo "Running: find \"$root\" -name '*.$ext'"
            find "$root" -name "*.$ext"
            ;;
        2)
            root=$(prompt_root)
            read -rp "Path pattern (e.g. */path/*/*.ext): " pathpat
            read -rp "Name pattern (e.g. *pattern*): " namepat
            echo "Running: find \"$root\" -path '$pathpat' -or -name '$namepat'"
            find "$root" -path "$pathpat" -or -name "$namepat"
            ;;
        3)
            root=$(prompt_root)
            read -rp "Directory name pattern (e.g. *lib*): " namepat
            echo "Running: find \"$root\" -type d -iname '$namepat'"
            find "$root" -type d -iname "$namepat"
            ;;
        4)
            root=$(prompt_root)
            read -rp "File name pattern (e.g. *.py): " namepat
            read -rp "Exclude path pattern (e.g. */site-packages/*): " excludepath
            echo "Running: find \"$root\" -name '$namepat' -not -path '$excludepath'"
            find "$root" -name "$namepat" -not -path "$excludepath"
            ;;
        5)
            root=$(prompt_root)
            read -rp "Max depth (e.g. 1): " maxdepth
            read -rp "Min size (e.g. +500k): " minsize
            read -rp "Max size (e.g. -10M): " maxsize
            echo "Running: find \"$root\" -maxdepth $maxdepth -size $minsize -size $maxsize"
            find "$root" -maxdepth "$maxdepth" -size "$minsize" -size "$maxsize"
            ;;
        6)
            root=$(prompt_root)
            read -rp "File name pattern (e.g. *.ext): " namepat
            read -rp "Command to run for each file (use {} for filename): " cmd
            echo "Running: find \"$root\" -name '$namepat' -exec $cmd \;"
            find "$root" -name "$namepat" -exec $cmd \;
            ;;
        7)
            root=$(prompt_root)
            read -rp "Command to run on all files (use {} for filename): " cmd
            echo "Running: find \"$root\" -daystart -mtime -1 -exec $cmd {} +"
            find "$root" -daystart -mtime -1 -exec $cmd {} +
            ;;
        8)
            root=$(prompt_root)
            echo "Running: find \"$root\" -type f -empty -print -delete"
            find "$root" -type f -empty -print -delete
            echo "Running: find \"$root\" -type d -empty -print -delete"
            find "$root" -type d -empty -print -delete
            ;;
        9)
            set_new_default
            ;;
        10)
            echo "Bye!"
            exit 0
            ;;
        *)
            echo "[!] Invalid choice"
            ;;
    esac
    echo
done
