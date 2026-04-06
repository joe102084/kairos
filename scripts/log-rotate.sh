#!/bin/zsh
# Kairos log rotation — truncate large persistent launchd logs only
# NEVER delete daily report logs (YYYY-MM-DD-*.log) — they are part of
# the second brain and must be preserved indefinitely.

# Truncate launchd logs (continuously appended, mtime always today) when >1MB
for f in $HOME/.kairos/logs/launchd-*.log; do
  if [ -f "$f" ] && [ $(stat -f%z "$f") -gt 1048576 ]; then
    tail -500 "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  fi
done
