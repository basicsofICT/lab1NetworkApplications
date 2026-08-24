#!/usr/bin/env bash
set -euo pipefail
base="${1:-http://127.0.0.1:3000}"

if ! echo "$base" | grep -Eq '^https?://(127\.0\.0\.1|localhost|0\.0\.0\.0|::1)(:|/|$)'; then
  echo "Refusing to enumerate non-local targets. Use http://127.0.0.1:3000"
  exit 2
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
wordlist="$ROOT/lab/wordlist.txt"
mkdir -p "$ROOT/artifacts"
out="$ROOT/artifacts/enum.txt"
body="$(mktemp)"
trap 'rm -f "$body"' EXIT
base="${base%/}"

{
  echo "== GET $base/robots.txt =="
  curl -sS --max-time 5 "$base/robots.txt" || true
  echo
  echo "== Path enumeration (lab wordlist) =="
  while IFS= read -r path || [[ -n "$path" ]]; do
    [[ -z "$path" || "$path" =~ ^# ]] && continue
    url="$base/${path#/}"
    code=$(curl -sS -o "$body" -w "%{http_code}" --max-time 5 "$url" || echo "000")
    echo "[$code] $url"
    if [[ "$code" =~ ^2 ]]; then
      echo "----- body (first 20 lines) -----"
      sed -n '1,20p' "$body"
      echo "-----"
    fi
  done < "$wordlist"
} | tee "$out"

echo
echo "[enum_web] Saved output to artifacts/enum.txt"
echo "[enum_web] Read robots.txt and any 200 responses, then paste the WEB_FLAG into yourAnswers.md"
