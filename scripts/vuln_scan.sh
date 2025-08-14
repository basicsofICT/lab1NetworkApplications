#!/usr/bin/env bash
set -euo pipefail
url="${1:-}"
if [[ -z "$url" ]]; then
  echo "Usage: $0 <http(s)://host[:port]>"
  exit 1
fi
echo "=== Nikto scan ($url) ==="
nikto -host "$url" -ask no -Display V
