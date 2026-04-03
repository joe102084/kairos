#!/bin/zsh
# Kairos Daily Briefing — Shell Wrapper
# Called by launchd or manually: ./kairos-briefing.sh [morning|evening]

set -euo pipefail

# Ensure PATH includes common locations for claude CLI
export PATH="/Users/jo/.nvm/versions/node/v25.2.1/bin:/usr/local/bin:/opt/homebrew/bin:$HOME/.local/bin:$PATH"

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

echo "=== Kairos ${BRIEFING_TYPE} briefing started at $(date) ===" >> "$LOG_FILE"

# Run claude -p with system prompt
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
echo "=== Kairos ${BRIEFING_TYPE} completed at $(date) ===" >> "$LOG_FILE"
