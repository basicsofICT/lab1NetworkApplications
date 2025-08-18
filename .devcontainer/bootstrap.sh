#!/usr/bin/env bash
set -euo pipefail

# Ensure we are in the workspace and scripts are executable
WS="/workspaces/${localWorkspaceFolderBasename:-$(basename $(pwd))}"
if [ ! -d "$WS" ]; then
  WS="/workspaces/$(basename $(pwd))"
fi

# Create expected dirs/files idempotently
mkdir -p "$WS/shares/public" "$WS/scripts"
[ -f "$WS/shares/public/readme.txt" ] || echo "Hello from the SMB share!" > "$WS/shares/public/readme.txt"

# Ensure our service scripts are executable if present
chmod +x "$WS"/scripts/*.sh 2>/dev/null || true
chmod +x "$WS"/.devcontainer/*.sh 2>/dev/null || true

echo "[bootstrap] Workspace ready at: $WS"
