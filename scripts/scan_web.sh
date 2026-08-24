#!/usr/bin/env bash
set -euo pipefail
target="${1:-}"
if [[ -z "$target" ]]; then
  echo "Usage: $0 <host-or-ip>"
  exit 1
fi

# Only allow loopback targets in this lab
if ! echo "$target" | grep -Eq '^(127\.0\.0\.1|localhost|::1)$'; then
  echo "Refusing to scan non-local targets. Use 127.0.0.1"
  exit 2
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/artifacts"
out="$ROOT/artifacts/scan.txt"

{
  echo "== TCP port scan (lab-relevant ports, connect scan) =="
  nmap -Pn -sT -T3 --max-retries 2 -p 22,80,443,3000,8000,8080,3306,5432 -oN - "$target"

  echo -e "\n== Service/version probe on lab web ports (3000,8080) =="
  echo "Note: nmap names ports from its default list (3000=ppp, 8080=http-proxy)."
  echo "      These lab apps are custom HTTP, so version detection may say 'unrecognized'."
  echo "      Use the curl Server: headers below for the Version column in yourAnswers.md."
  # Drop the long SF- fingerprint dump — it is nmap asking you to submit a signature, not an error.
  nmap -Pn -sV -sT -T3 -p 3000,8080 --version-light -oN - "$target" \
    | grep -vE '^SF-|^SF:|^====' || true

  echo -e "\n== Quick HTTP head checks (use these for Service / Version) =="
  for p in 3000 8080; do
    if nc -z -w1 "$target" "$p" 2>/dev/null; then
      echo -e "\n-- http://$target:$p --"
      curl -sI --max-time 5 "http://$target:$p" | sed -n '1,20p' || true
    fi
  done
} | tee "$out"

echo
echo "[scan_web] Saved output to artifacts/scan.txt"
