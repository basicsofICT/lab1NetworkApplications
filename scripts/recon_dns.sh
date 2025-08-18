#!/usr/bin/env bash
set -euo pipefail
domain="${1:-}"
if [[ -z "$domain" ]]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

echo "== WHOIS =="
whois "$domain" | sed -n '1,120p' || true

echo -e "\n== DNS Records =="
echo "-- NS --";    dig +nocmd "$domain" NS +noall +answer || true
echo "-- A --";     dig +nocmd "$domain" A  +noall +answer || true
echo "-- AAAA --";  dig +nocmd "$domain" AAAA +noall +answer || true
echo "-- SOA --";   dig +nocmd "$domain" SOA +noall +answer || true
