#!/usr/bin/env bash
set -euo pipefail
url="${1:-}"
if [[ -z "$url" ]]; then echo "Usage: $0 <http(s)://host:port>"; exit 1; fi

# Hard guard: only allow localhost / loopback targets to avoid mistakes.
if ! echo "$url" | grep -Eq '^https?://(127\.0\.0\.1|localhost|0\.0\.0\.0|::1)(:|/|$)'; then
  echo "Refusing to scan non-local targets. Point at http://127.0.0.1:PORT"; exit 2
fi

echo "== Nikto (light, local) =="
nikto -host "$url" -Tuning x  -timeout 5 -maxtime 5m -nolookup -ask no
