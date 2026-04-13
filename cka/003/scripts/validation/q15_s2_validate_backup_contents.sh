#!/bin/bash
BACKUP_FILE="/opt/backup-task.yaml"
if [[ ! -f "$BACKUP_FILE" ]]; then
  echo "❌ Namespace backup not found at $BACKUP_FILE"; exit 1
fi
if ! grep -q "kind: Deployment" "$BACKUP_FILE" || ! grep -q "name: backup-app" "$BACKUP_FILE"; then
  echo "❌ Backup file does not include Deployment backup-app"; exit 1
fi
if ! grep -q "kind: ConfigMap" "$BACKUP_FILE" || ! grep -q "name: app-settings" "$BACKUP_FILE"; then
  echo "❌ Backup file does not include ConfigMap app-settings"; exit 1
fi
if ! grep -q "namespace: backup-task" "$BACKUP_FILE"; then
  echo "❌ Backup file does not include namespace backup-task"; exit 1
fi
echo "✅ Namespace backup contains backup-app and app-settings"; exit 0
