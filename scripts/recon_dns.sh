
---

### scripts/recon_dns.sh
```bash
#!/usr/bin/env bash
set -euo pipefail
domain="${1:-}"
if [[ -z "$domain" ]]; then
  echo "Usage: $0 <domain>"
  exit 1
fi
echo "=== WHOIS ($domain) ==="
whois "$domain" | sed -e 's/\r$//' | sed -n '1,120p'
echo
echo "=== DIG A/AAAA ($domain) ==="
dig +short A "$domain"
dig +short AAAA "$domain"
echo
echo "=== Nameservers ($domain) ==="
dig +short NS "$domain"
echo
echo "=== NSLOOKUP ($domain) ==="
nslookup "$domain" || true
