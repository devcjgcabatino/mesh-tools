#!/usr/bin/env bash
# quickserve — serve current dir over HTTP
set -euo pipefail

PORT="${1:-8000}"
IP=$(hostname -I 2>/dev/null | awk '{print $1}')
echo "[*] Serving $(pwd) at: http://$IP:$PORT"
echo "[CTRL+C to stop]"
python3 -m http.server "$PORT"
