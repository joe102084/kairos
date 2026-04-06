#!/bin/zsh
# Kairos log rotation — truncate large persistent logs, delete old daily logs

# Truncate launchd logs (continuously appended, mtime always today) when >1MB
for f in $HOME/.kairos/logs/*.log; do
  if [ -f "$f" ] && [ $(stat -f%z "$f") -gt 1048576 ]; then
    tail -500 "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  fi
done

# Delete daily report logs (YYYY-MM-DD-*.log, written once) older than 30 days
find $HOME/.kairos/logs -name "20*-*-*.log" -mtime +30 -delete
