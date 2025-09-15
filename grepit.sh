#!/usr/bin/env bash
# grepit — interactive grep wrapper
set -euo pipefail

read -rp "Search term/pattern: " pattern
read -rp "Root path [$(pwd)]: " root
root="${root:-$(pwd)}"
read -rp "Case-insensitive? (y/N): " ci
read -rp "Use regex? (y/N): " rgx

opts=()
[[ "$ci" =~ ^[Yy]$ ]] && opts+=("-i")
[[ "$rgx" =~ ^[Yy]$ ]] || opts+=("-F")

grep --color=always -Rn "${opts[@]}" "$pattern" "$root"
