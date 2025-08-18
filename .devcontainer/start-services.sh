#!/usr/bin/env bash
# Start lab services without Docker (SMB removed):
#  - HTTP :3000 (python http.server)
#  - HTTP :8080 (python http.server)
# Requires: python3, curl, netcat-traditional (installed in postCreateCommand)

set -euo pipefail

# ---- Workspace paths ----
WS="/workspaces/${localWorkspaceFolderBasename:-$(basename "$(pwd)")}"
[ -d "$WS" ] || WS="/workspaces/$(basename "$(pwd)")"
LOG="$WS/.logs"
mkdir -p "$LOG"

echo "[start-services] Workspace: $WS"
echo "[start-services] Logs in: $LOG/"

# ---- HTTP :3000 ----
if ! ss -ltn | awk '{print $4}' | grep -q ':3000$'; then
  echo "[start-services] Starting http.server on :3000 ..."
  nohup bash -lc "cd \"$WS\" && python3 -m http.server 3000 --bind 0.0.0.0" >"$LOG/http-3000.out" 2>&1 &
else
  echo "[start-services] :3000 already listening."
fi

# ---- HTTP :8080 ----
if ! ss -ltn | awk '{print $4}' | grep -q ':8080$'; then
  echo "[start-services] Starting http.server on :8080 ..."
  nohup bash -lc "cd \"$WS\" && python3 -m http.server 8080 --bind 0.0.0.0" >"$LOG/http-8080.out" 2>&1 &
else
  echo "[start-services] :8080 already listening."
fi

# ---- Summary ----
sleep 2
echo
echo "[start-services] Status:"
for port in 3000 8080; do
  if ss -ltn | awk '{print $4}' | grep -q ":$port$"; then
    echo "  ✓ Port $port is listening"
  else
    echo "  ✗ Port $port not listening (see $LOG/http-$port.out)"
  fi
done

echo
echo "[start-services] Quick checks:"
( curl -sI http://127.0.0.1:3000 | sed -n '1,2p' ) || true
( curl -sI http://127.0.0.1:8080 | sed -n '1,2p' ) || true

echo
echo "[start-services] Done."
