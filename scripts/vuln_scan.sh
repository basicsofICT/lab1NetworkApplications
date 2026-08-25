#!/usr/bin/env bash
set -euo pipefail
url="${1:-}"
if [[ -z "$url" ]]; then
  echo "Usage: $0 <http(s)://host:port>"
  exit 1
fi

if ! echo "$url" | grep -Eq '^https?://(127\.0\.0\.1|localhost|0\.0\.0\.0|::1)(:|/|$)'; then
  echo "Refusing to scan non-local targets. Use http://127.0.0.1:PORT"
  exit 2
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/artifacts"
out="$ROOT/artifacts/nikto.txt"

{
  echo "== Missing security headers (copy two of these names) =="
  hdrs="$(curl -sI --max-time 5 "$url" || true)"
  for h in X-Frame-Options Content-Security-Policy Strict-Transport-Security X-Content-Type-Options; do
    if echo "$hdrs" | grep -qi "^${h}:"; then
      echo "present: $h"
    else
      echo "MISSING: $h"
    fi
  done
  echo
  echo "== HTTP response headers (curl -I) =="
  echo "$hdrs"
  echo
  echo "== Nikto (local) =="
  nikto -host "$url" -timeout 5 -maxtime 5m -nolookup -ask no || true
} | tee "$out"

echo
echo "[vuln_scan] Saved output to artifacts/nikto.txt"
echo "[vuln_scan] Use two names from the MISSING lines for yourAnswers.md"
