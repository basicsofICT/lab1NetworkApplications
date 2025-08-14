#!/usr/bin/env bash
set -euo pipefail
target="${1:-}"
if [[ -z "$target" ]]; then
  echo "Usage: $0 <host-or-ip>"
  exit 1
fi
echo "=== TCP scan & service detect ==="
nmap -Pn -sS -sV -O --version-light --top-ports 100 "$target"
echo
echo "=== Fast http(s) banner check (common ports) ==="
for p in 80 443 8080 8443; do
  (echo > /dev/tcp/"$target"/"$p") >/dev/null 2>&1 && {
    echo "Port $p open — grabbing headers..."
    printf 'HEAD / HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$target" | timeout 5 bash -c "cat > /dev/tcp/$target/$p" 2>/dev/null || true
  }
done
