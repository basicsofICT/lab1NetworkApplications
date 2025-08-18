#!/usr/bin/env bash
set -euo pipefail

# Resolve workspace path robustly
WS="/workspaces/${localWorkspaceFolderBasename:-$(basename $(pwd))}"
if [ ! -d "$WS" ]; then
  WS="/workspaces/$(basename $(pwd))"
fi

LOG="$WS/.logs"
SMB_DIR="$WS/.smb"
mkdir -p "$LOG" "$SMB_DIR"/{cache,logs,lib,run}
mkdir -p "$WS/shares/public"
[ -f "$WS/shares/public/readme.txt" ] || echo "Hello from the SMB share!" > "$WS/shares/public/readme.txt"

echo "[start-services] Using workspace: $WS"

# --- Start Juice Shop on :3000 ---
if ! pgrep -f "juice-shop --port 3000" >/dev/null 2>&1; then
  echo "[start-services] Starting Juice Shop..."
  nohup bash -lc "juice-shop --port 3000" >"$LOG/juice-shop.out" 2>&1 &
else
  echo "[start-services] Juice Shop already running."
fi

# --- Start httpbin on :8080 ---
if ! pgrep -f "gunicorn httpbin:app -b 0.0.0.0:8080" >/dev/null 2>&1; then
  echo "[start-services] Starting httpbin..."
  nohup bash -lc "python3 -m gunicorn httpbin:app -b 0.0.0.0:8080 --workers 2" >"$LOG/httpbin.out" 2>&1 &
else
  echo "[start-services] httpbin already running."
fi

# --- Samba config on :1445 (unprivileged) ---
cat > "$SMB_DIR/smb.conf" <<CONF
[global]
   workgroup = WORKGROUP
   server role = standalone server
   map to guest = Bad User
   logging = file
   log file = $SMB_DIR/logs/smbd.log
   max log size = 50
   smb ports = 1445

[public]
   path = $WS/shares/public
   browseable = yes
   read only = yes
   guest ok = yes
CONF

# Start smbd on 1445 if not running
if ! ss -ltn | awk '{print $4}' | grep -q ':1445$'; then
  echo "[start-services] Starting smbd on 1445..."
  nohup bash -lc "smbd --foreground --no-process-group --configfile=$SMB_DIR/smb.conf --piddir=$SMB_DIR/run --cachedir=$SMB_DIR/cache --state-directory=$SMB_DIR/lib --lock-directory=$SMB_DIR/lib" >"$LOG/smbd.out" 2>&1 &
else
  echo "[start-services] smbd appears to be listening on 1445."
fi

echo "[start-services] Launched. Logs in $LOG/"
