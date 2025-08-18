#!/usr/bin/env bash
set -euo pipefail
ip="${1:-}"
port="${2:-1445}"
if [[ -z "$ip" ]]; then
  echo "Usage: $0 <target-ip> [port(default 1445)]"
  exit 1
fi

echo "== SMB Shares (guest/anonymous) on $ip:$port =="
smbclient -L "//$ip" -N -p "$port" -g || echo "Guest listing failed (expected if disabled)."

echo -e "\n== Try listing 'public' share (guest) =="
smbclient "//${ip}/public" -N -p "$port" -c "ls; quit" || echo "Could not access public share."
