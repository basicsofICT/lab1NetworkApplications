#!/usr/bin/env bash
# Minimal, robust service launcher for Codespaces (no Docker).
# Starts:
#   - Simple HTTP server on :3000  (python http.server)
#   - Simple HTTP server on :8080  (python http.server)
#   - smbd on :1445 (guest-readable 'public' share)
# Requires (install once if missing):
#   sudo apt-get update && sudo apt-get install -y python3 samba smbclient curl netcat-traditional

set -euo pipefail

# ---- Workspace & dirs ----
WS="/workspaces/${localWorkspaceFolderBasename:-$(basename "$(pwd)")}"
[ -d "$WS" ] || WS="/workspaces/$(basename "$(pwd)")"

LOG="$WS/.logs"
SMB_DIR="$WS/.smb"
mkdir -p "$LOG" "$WS/shares/public" "$SMB_DIR"/{logs,run,locks,state,cache}

# Ensure share has a file
[ -f "$WS/shares/public/readme.txt" ] || echo "Hello from the SMB share!" > "$WS/shares/public/readme.txt"

echo "[start-services] Workspace: $WS"
echo "[start-services] Logs in: $LOG/"

# ---- HTTP on :3000 (simple) ----
if ! ss -ltn | awk '{print $4}' | grep -q ':3000$'; then
  echo "[start-services] Starting python http.server on :3000 ..."
  nohup bash -lc "cd \"$WS\" && python3 -m http.server 3000 --bind 0.0.0.0" >"$LOG/http-3000.out" 2>&1 &
else
  echo "[start-services] :3000 already listening."
fi

# ---- HTTP on :8080 (simple) ----
if ! ss -ltn | awk '{print $4}' | grep -q ':8080$'; then
  echo "[start-services] Starting python http.server on :8080 ..."
  nohup bash -lc "cd \"$WS\" && python3 -m http.server 8080 --bind 0.0.0.0" >"$LOG/http-8080.out" 2>&1 &
else
  echo "[start-services] :8080 already listening."
fi

# ---- Samba config for :1445 (all paths inside workspace) ----
cat > "$SMB_DIR/smb.conf" <<CONF
[global]
   workgroup = WORKGROUP
   server role = standalone server
   map to guest = Bad User

   # keep all Samba state/logs inside the workspace
   log file = $SMB_DIR/logs/samba.log
   pid directory = $SMB_DIR/run
   lock directory = $SMB_DIR/locks
   state directory = $SMB_DIR/state
   cache directory = $SMB_DIR/cache

   # listen on unprivileged port (Codespaces-safe)
   smb ports = 1445

[public]
   path = $WS/shares/public
   browseable = yes
   read only = yes
   guest ok = yes
CONF

# ---- Start smbd on :1445 ----
if ! ss -ltn | awk '{print $4}' | grep -q ':1445$'; then
  echo "[start-services] Starting smbd on :1445 ..."
  # -F foreground (nohup backgrounds it), -s config, -l log dir
  nohup smbd -F -s "$SMB_DIR/smb.conf" -l "$SMB_DIR/logs" >"$LOG/smbd.out" 2>&1 &
else
  echo "[start-services] smbd already listening on :1445."
fi

# ---- Summarize ----
sleep 2
echo
echo "[start-services] Status:"
for port in 3000 8080 1445; do
  if ss -ltn | awk '{print $4}' | grep -q ":$port$"; then
    echo "  ✓ Port $port is listening"
  else
    echo "  ✗ Port $port not listening (check $LOG/*.out)"
  fi
done

echo
echo "[start-services] Quick checks:"
( curl -sI http://127.0.0.1:3000 | sed -n '1,2p' ) || true
( curl -sI http://127.0.0.1:8080 | sed -n '1,2p' ) || true
( smbclient -L //127.0.0.1 -N -p 1445 | sed -n '1,20p' ) || true

echo
echo "[start-services] Done."
