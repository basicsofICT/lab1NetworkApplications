#!/usr/bin/env bash
set -euo pipefail
domain="${1:-}"
if [[ -z "$domain" ]]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/artifacts"
out="$ROOT/artifacts/recon.txt"

{
  echo "== WHOIS =="
  whois "$domain" | sed -n '1,120p' || true

  echo -e "\n== DNS Records =="
  echo "-- NS --";    dig +nocmd "$domain" NS +noall +answer || true
  echo "-- A --";     dig +nocmd "$domain" A  +noall +answer || true
  echo "-- AAAA --";  dig +nocmd "$domain" AAAA +noall +answer || true
  echo "-- MX --";    dig +nocmd "$domain" MX +noall +answer || true
  echo "-- TXT --";   dig +nocmd "$domain" TXT +noall +answer || true
  echo "-- SOA --";   dig +nocmd "$domain" SOA +noall +answer || true
} | tee "$out"

echo
echo "[recon_dns] Saved output to artifacts/recon.txt"
