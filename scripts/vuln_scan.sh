#!/usr/bin/env bash
set -euo pipefail
url="${1:-}"
if [[ -z "$url" ]]; then
  echo "Usage: $0 <http(s)://host:port>"
  exit 1
fi

# Only allow loopback targets
if ! echo "$url" | grep -Eq '^https?://(127\.0\.0\.1|localhost|0\.0\.0\.0|::1)(:|/|$)'; then
  echo "Refusing to scan non-local targets. Use http://127.0.0.1:PORT"
  exit 2
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/artifacts"
out="$ROOT/artifacts/nikto.txt"

{
  echo "== Nikto (light, local) =="
  nikto -host "$url" -Tuning x -timeout 5 -maxtime 5m -nolookup -ask no
} | tee "$out"

echo
echo "[vuln_scan] Saved output to artifacts/nikto.txt"
