#!/usr/bin/env bash
set -euo pipefail
target="${1:-}"
if [[ -z "$target" ]]; then
  echo "Usage: $0 <target-ip>"
  exit 1
fi

echo "=== NetBIOS name lookup ==="
nmblookup -A "$target" || true
echo
echo "=== SMB shares (guest/anonymous) ==="
smbclient -L "//$target/" -N || true
echo
echo "=== Try basic RPC info (no creds) ==="
echo "srvinfo" | rpcclient -U "" -N "$target" || true
