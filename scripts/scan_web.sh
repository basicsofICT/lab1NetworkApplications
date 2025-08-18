#!/usr/bin/env bash
set -euo pipefail
target="${1:-}"
if [[ -z "$target" ]]; then
  echo "Usage: $0 <host-or-ip>"
  exit 1
fi

echo "== TCP Port scan (top 1000, safe timing) =="
nmap -Pn -sS -T3 --max-retries 2 --max-rate 50 --top-ports 1000 -oN - "$target"

echo -e "\n== Focused service probe on lab ports (80,443,3000,8080,1445) =="
LAB_PORTS="80,443,3000,8080,1445"
nmap -Pn -sV -T3 -p "$LAB_PORTS" --version-light -oN - "$target"

echo -e "\n== Quick HTTP(S) head checks =="
for p in 80 443 3000 8080; do
  if nc -z -w1 "$target" "$p" 2>/dev/null; then
    scheme="http"; [[ "$p" == "443" ]] && scheme="https"
    echo -e "\n-- $scheme://$target:$p --"
    curl -kIs --max-time 5 "$scheme://$target:$p" | sed -n '1,15p' || true
  fi
done

# SMB (non-standard port in this lab)
if nc -z -w2 "$target" 1445 2>/dev/null; then
  echo -e "\n-- SMB detected on $target:1445 (remapped from 445). Use enumerate_smb.sh to list shares."
fi
