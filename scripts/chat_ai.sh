#!/usr/bin/env bash
set -euo pipefail
msg="${1:-}"
if [[ -z "$msg" ]]; then
  echo "Usage: $0 \"your message to CampusBot\""
  echo "Example: $0 \"Hello\""
  exit 1
fi

url="${CHAT_URL:-http://127.0.0.1:8080/chat}"
if ! echo "$url" | grep -Eq '^https?://(127\.0\.0\.1|localhost|0\.0\.0\.0|::1)(:|/|$)'; then
  echo "Refusing to contact a non-local chatbot."
  exit 2
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/artifacts"
out="$ROOT/artifacts/chat.txt"

payload=$(jq -n --arg m "$msg" '{message:$m}')
{
  echo "== You =="
  echo "$msg"
  echo
  echo "== CampusBot =="
  curl -sS --max-time 10 -H "Content-Type: application/json" -d "$payload" "$url" | jq -r '.reply // .'
  echo
} | tee -a "$out"

echo
echo "[chat_ai] Appended transcript to artifacts/chat.txt"
