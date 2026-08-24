#!/usr/bin/env bash
# Start lab services:
#  - HTTP :3000  intentionally insecure campus portal (lab/webapp.py)
#  - HTTP :8080  CampusBot chatbot (lab/chatbot.py)

set -euo pipefail

WS="/workspaces/${localWorkspaceFolderBasename:-$(basename "$(pwd)")}"
[ -d "$WS" ] || WS="/workspaces/$(basename "$(pwd)")"
[ -d "$WS/lab" ] || WS="$(cd "$(dirname "$0")/.." && pwd)"

LOG="$WS/.logs"
mkdir -p "$LOG" "$WS/artifacts"

echo "[start-services] Workspace: $WS"
echo "[start-services] Logs in: $LOG/"

start_python() {
  local name="$1"
  local port="$2"
  local script="$3"
  if ss -ltn | awk '{print $4}' | grep -q ":${port}$"; then
    echo "[start-services] :${port} already listening ($name)."
    return
  fi
  echo "[start-services] Starting $name on :${port} ..."
  nohup python3 "$script" >"$LOG/${name}.out" 2>&1 &
}

start_python "webapp" 3000 "$WS/lab/webapp.py"
start_python "chatbot" 8080 "$WS/lab/chatbot.py"

for _ in 1 2 3 4 5 6 7 8; do
  if curl -sf http://127.0.0.1:3000/health >/dev/null && curl -sf http://127.0.0.1:8080/health >/dev/null; then
    break
  fi
  sleep 1
done
echo
echo "[start-services] Status:"
for port in 3000 8080; do
  if ss -ltn | awk '{print $4}' | grep -q ":$port$"; then
    echo "  ✓ Port $port is listening"
  else
    echo "  ✗ Port $port not listening (see $LOG/)"
  fi
done

echo
echo "[start-services] Quick checks:"
( curl -sI http://127.0.0.1:3000 | sed -n '1,5p' ) || true
( curl -sI http://127.0.0.1:8080 | sed -n '1,5p' ) || true

echo
echo "[start-services] Done."
echo "  Portal:    http://127.0.0.1:3000"
echo "  CampusBot: http://127.0.0.1:8080"
