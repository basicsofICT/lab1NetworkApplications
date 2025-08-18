#!/usr/bin/env bash
set -euo pipefail
domain="${1:-}"
if [[ -z "$domain" ]]; then echo "Usage: $0 <domain>"; exit 1; fi

echo "== WHOIS (redacted output may vary) =="
whois "$domain" | sed -n '1,120p'

echo -e "\n== DNS Records =="
echo "-- NS --";    dig +nocmd "$domain" NS +noall +answer
echo "-- A --";     dig +nocmd "$domain" A  +noall +answer
echo "-- AAAA --";  dig +nocmd "$domain" AAAA +noall +answer
echo "-- SOA --";   dig +nocmd "$domain" SOA +noall +answer
