#!/usr/bin/env bash
set -euo pipefail
ip="${1:-}"
if [[ -z "$ip" ]]; then echo "Usage: $0 <target-ip>"; exit 1; fi

echo "== SMB Shares (guest/anonymous) =="
smbclient -L "//$ip" -N -g || echo "Guest listing failed (expected if disabled)."

echo -e "\n== Try listing 'public' share (guest) =="
smbclient "//${ip}/public" -N -c "ls; quit" || echo "Could not access public share."
