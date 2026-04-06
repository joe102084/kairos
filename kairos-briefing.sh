#!/bin/zsh
# Kairos Daily Briefing — Shell Wrapper
# Called by launchd or manually: ./kairos-briefing.sh [morning|evening]

set -euo pipefail

# Load nvm dynamically (no hardcoded Node version)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
export PATH="/usr/local/bin:/opt/homebrew/bin:$HOME/.local/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.env"

# Kill switch
if [[ "$KAIROS_ENABLED" != "true" ]]; then
  echo "$(date): Kairos disabled via KAIROS_ENABLED" >> "$SCRIPT_DIR/logs/kairos.log"
  exit 0
fi

# Determine briefing type
BRIEFING_TYPE="${1:-morning}"
if [[ "$BRIEFING_TYPE" != "morning" && "$BRIEFING_TYPE" != "evening" ]]; then
  echo "Usage: $0 [morning|evening]" >&2
  exit 1
fi

# Compute dates in SGT
TODAY=$(TZ=Asia/Singapore date +%Y-%m-%d)
YESTERDAY=$(TZ=Asia/Singapore date -v-1d +%Y-%m-%d)
TOMORROW=$(TZ=Asia/Singapore date -v+1d +%Y-%m-%d)
DAY_NAME=$(TZ=Asia/Singapore date +%A)

# Read and substitute template
TEMPLATE="$SCRIPT_DIR/templates/${BRIEFING_TYPE}.md"
if [[ ! -f "$TEMPLATE" ]]; then
  echo "$(date): Template not found: $TEMPLATE" >> "$SCRIPT_DIR/logs/kairos.log"
  exit 1
fi

PROMPT=$(cat "$TEMPLATE" | \
  sed "s|{{TODAY}}|$TODAY|g" | \
  sed "s|{{YESTERDAY}}|$YESTERDAY|g" | \
  sed "s|{{TOMORROW}}|$TOMORROW|g" | \
  sed "s|{{DAY_NAME}}|$DAY_NAME|g" | \
  sed "s|{{VAULT_PATH}}|$KAIROS_VAULT_PATH|g")

# Log file for this run
LOG_FILE="$SCRIPT_DIR/logs/${TODAY}-${BRIEFING_TYPE}.log"

echo "=== Kairos ${BRIEFING_TYPE} started at $(date) ===" >> "$LOG_FILE"

# Run claude -p — generates briefing text to stdout
run_briefing() {
  "$KAIROS_CLI" -p "$PROMPT" \
    --system-prompt-file "$SCRIPT_DIR/kairos-system.md" \
    --model "$KAIROS_MODEL" \
    --dangerously-skip-permissions \
    2>&1
}

OUTPUT=$(run_briefing) || {
  EXIT_CODE=$?
  echo "First attempt failed (exit $EXIT_CODE). Retrying in 60s..." >> "$LOG_FILE"
  echo "$OUTPUT" >> "$LOG_FILE"
  sleep 60
  OUTPUT=$(run_briefing) || {
    EXIT_CODE=$?
    echo "Retry also failed (exit $EXIT_CODE)." >> "$LOG_FILE"
    echo "$OUTPUT" >> "$LOG_FILE"
    echo "=== Kairos ${BRIEFING_TYPE} FAILED at $(date) ===" >> "$LOG_FILE"
    exit $EXIT_CODE
  }
}

echo "$OUTPUT" >> "$LOG_FILE"

# Use claude output directly as briefing text, truncated to Telegram limit
BRIEFING=$(echo "$OUTPUT" | head -c 2000)

# Send via Telegram Bot API (direct HTTP — no MCP dependency)
# Use --data-urlencode for proper encoding of message text
RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot${KAIROS_BOT_TOKEN}/sendMessage" \
  --data-urlencode "text=$BRIEFING" \
  -d "chat_id=$KAIROS_CHAT_ID" \
  -d "parse_mode=Markdown" 2>&1)

# Check delivery — extract "ok" field robustly
if echo "$RESPONSE" | grep -q '"ok":true'; then
  MSG_ID=$(echo "$RESPONSE" | grep -o '"message_id":[0-9]*' | head -1 | grep -o '[0-9]*')
  echo "Telegram delivered: message_id=$MSG_ID" >> "$LOG_FILE"
else
  echo "Markdown delivery failed. Retrying as plain text..." >> "$LOG_FILE"
  RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot${KAIROS_BOT_TOKEN}/sendMessage" \
    --data-urlencode "text=$BRIEFING" \
    -d "chat_id=$KAIROS_CHAT_ID" 2>&1)
  if echo "$RESPONSE" | grep -q '"ok":true'; then
    MSG_ID=$(echo "$RESPONSE" | grep -o '"message_id":[0-9]*' | head -1 | grep -o '[0-9]*')
    echo "Telegram delivered (plain text): message_id=$MSG_ID" >> "$LOG_FILE"
  else
    echo "Telegram delivery FAILED. Response: $RESPONSE" >> "$LOG_FILE"
  fi
fi

echo "=== Kairos ${BRIEFING_TYPE} completed at $(date) ===" >> "$LOG_FILE"
