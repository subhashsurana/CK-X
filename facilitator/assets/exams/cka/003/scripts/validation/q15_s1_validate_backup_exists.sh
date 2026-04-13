#!/bin/bash
BACKUP_FILE="/opt/backup-task.yaml"
if [[ ! -f "$BACKUP_FILE" ]]; then
  echo "❌ Namespace backup not found at $BACKUP_FILE"; exit 1
fi
SIZE=$(stat -c%s "$BACKUP_FILE" 2>/dev/null)
if [[ "$SIZE" -lt 100 ]]; then
  echo "❌ Namespace backup file seems too small ($SIZE bytes) — may be empty"; exit 1
fi
echo "✅ Namespace backup exists at $BACKUP_FILE (${SIZE} bytes)"; exit 0
