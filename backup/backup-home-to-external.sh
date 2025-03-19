#!/bin/bash

# --ignore-missing-args --links
# --dry-run
# --progress

SRC_DIR="$HOME/"
DEST_DIR="/media/$USER/chdev/linux/"
EXCLUDE_FILE="$HOME/rsync-exclude.txt"
LOG_FILE="$HOME/backup.log"

echo "=== $(date) - Rsync Backup started ===" >> "$LOG_FILE"

rsync \
  -av \
  --exclude-from="$EXCLUDE_FILE" \
  --no-links \
  --ignore-errors \
  --ignore-missing-args \
  "$SRC_DIR" "$DEST_DIR" >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
  echo "=== $(date) - Backup Completed ===" >> "$LOG_FILE"
else
  echo "!!! $(date) - Backup completed with errors, see the log file: $LOG_FILE" >> "$LOG_FILE"
fi
