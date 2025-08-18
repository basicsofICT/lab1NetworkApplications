#!/usr/bin/env bash
set -euo pipefail

WORKDIR="${WORKDIR:-/workspaces/$(basename "$(pwd)")}"

# Ensure share and sample file exist
mkdir -p "$WORKDIR/shares/public"
if [ ! -f "$WORKDIR/shares/public/readme.txt" ]; then
  echo "Hello from the SMB share!" > "$WORKDIR/shares/public/readme.txt"
fi

# Start Juice Shop (:3000) via pm2
if ! pm2 list | grep -q "juice-shop"; then
  pm2 start "juice-shop --port 3000" --name juice-shop
fi

# Start httpbin (:8080) via gunicorn, managed by pm2
if ! pm2 list | grep -q "httpbin"; then
  pm2 start "bash -lc 'python3 -m gunicorn httpbin:app -b 0.0.0.0:8080 --workers 2'" --name httpbin
fi

# Minimal Samba config on unprivileged port 1445
SMB_ROOT="$WORKDIR/.smb"
mkdir -p "$SMB_ROOT"/{cache,logs,lib,run}
cat > "$SMB_ROOT/smb.conf" <<'CONF'
[global]
   workgroup = WORKGROUP
   server role = standalone server
   map to guest = Bad User
   logging = file
   log file = /workspaces/*/.smb/logs/smbd.log
   max log size = 50
   smb ports = 1445

[public]
   path = /workspaces/*/shares/public
   browseable = yes
   read only = yes
   guest ok = yes
CONF

# Replace wildcard path with actual workspace path
sed -i "s#/workspaces/*#$WORKDIR#g" "$SMB_ROOT/smb.conf"

# Start smbd in foreground on port 1445, managed by pm2
if ! pm2 list | grep -q "smbd"; then
  pm2 start "bash -lc 'smbd --foreground --no-process-group --debug-stdout --configfile=$SMB_ROOT/smb.conf --piddir=$SMB_ROOT/run --cachedir=$SMB_ROOT/cache --state-directory=$SMB_ROOT/lib --lock-directory=$SMB_ROOT/lib'" --name smbd
fi

# Persist pm2 process list
pm2 save >/dev/null 2>&1 || true

echo "Services up: Juice Shop :3000, httpbin :8080, SMB :1445"
