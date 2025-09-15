#!/usr/bin/env bash
# syswatch — quick system info
set -euo pipefail

echo "=== System Info ==="
uptime
echo
echo "=== CPU Load ==="
grep 'model name' /proc/cpuinfo | head -1
uptime | awk -F'load average:' '{ print "Load Average:" $2 }'
echo
echo "=== Memory ==="
free -h
echo
echo "=== Disk Usage ==="
df -h --total | grep -E 'Filesystem|total'
