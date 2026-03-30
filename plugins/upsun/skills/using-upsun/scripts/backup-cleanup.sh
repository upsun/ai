#!/bin/bash
# Delete old backups, keeping only the N most recent.
# Usage: ./backup-cleanup.sh <PROJECT_ID> <ENVIRONMENT> [KEEP_COUNT]

PROJECT="${1:?Usage: $0 <PROJECT_ID> <ENVIRONMENT> [KEEP_COUNT]}"
ENV="${2:?Usage: $0 <PROJECT_ID> <ENVIRONMENT> [KEEP_COUNT]}"
KEEP_COUNT="${3:-7}"

echo "Cleaning up old backups, keeping $KEEP_COUNT most recent..."

BACKUPS=$(upsun backup:list -p "$PROJECT" -e "$ENV" --pipe)
BACKUP_COUNT=$(echo "$BACKUPS" | wc -l)

if [ "$BACKUP_COUNT" -le "$KEEP_COUNT" ]; then
    echo "Only $BACKUP_COUNT backups exist, nothing to delete"
    exit 0
fi

DELETE_COUNT=$((BACKUP_COUNT - KEEP_COUNT))
echo "Deleting $DELETE_COUNT old backups..."

echo "$BACKUPS" | tail -n "$DELETE_COUNT" | while read BACKUP_ID; do
    echo "Deleting backup: $BACKUP_ID"
    upsun backup:delete "$BACKUP_ID" -p "$PROJECT" -e "$ENV" -y
done

echo "Cleanup complete"
