#!/bin/bash
# Create a backup and verify it completed successfully.
# Usage: ./automated-backup.sh <PROJECT_ID> <ENVIRONMENT> [--live]

PROJECT="${1:?Usage: $0 <PROJECT_ID> <ENVIRONMENT> [--live]}"
ENV="${2:?Usage: $0 <PROJECT_ID> <ENVIRONMENT> [--live]}"
LIVE_FLAG="${3:-}"

echo "Creating backup of $ENV environment..."
BACKUP_OUTPUT=$(upsun backup:create -p "$PROJECT" -e "$ENV" $LIVE_FLAG 2>&1)

if [ $? -eq 0 ]; then
    echo "Backup created successfully"
    BACKUP_ID=$(echo "$BACKUP_OUTPUT" | grep -oP 'backup:\K[a-z0-9]+')
    echo "Backup ID: $BACKUP_ID"
    sleep 30
    upsun backup:get "$BACKUP_ID" -p "$PROJECT" -e "$ENV"
else
    echo "Backup failed"
    echo "$BACKUP_OUTPUT"
    exit 1
fi
