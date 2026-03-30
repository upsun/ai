#!/bin/bash
# Safely restore a backup: creates a safety backup first, restores, then verifies.
# Usage: ./safe-restore.sh <PROJECT_ID> <ENVIRONMENT> <BACKUP_ID>

PROJECT="${1:?Usage: $0 <PROJECT_ID> <ENVIRONMENT> <BACKUP_ID>}"
ENV="${2:?Usage: $0 <PROJECT_ID> <ENVIRONMENT> <BACKUP_ID>}"
BACKUP_ID="${3:?Usage: $0 <PROJECT_ID> <ENVIRONMENT> <BACKUP_ID>}"

echo "Starting safe restore procedure..."

# Step 1: Verify backup exists
echo "1. Verifying backup..."
upsun backup:get "$BACKUP_ID" -p "$PROJECT" -e "$ENV" || {
    echo "Backup not found or invalid"
    exit 1
}

# Step 2: Create pre-restore safety backup
echo "2. Creating pre-restore safety backup..."
PRE_RESTORE_OUTPUT=$(upsun backup:create -p "$PROJECT" -e "$ENV" --live 2>&1)
PRE_RESTORE_ID=$(echo "$PRE_RESTORE_OUTPUT" | grep -oP 'backup:\K[a-z0-9]+')
echo "Pre-restore backup ID: $PRE_RESTORE_ID"

# Step 3: Wait and verify safety backup
echo "3. Waiting for safety backup..."
sleep 30
upsun backup:get "$PRE_RESTORE_ID" -p "$PROJECT" -e "$ENV" || {
    echo "Pre-restore backup failed"
    exit 1
}

# Step 4: Perform restore
echo "4. Performing restore..."
upsun backup:restore "$BACKUP_ID" -p "$PROJECT" -e "$ENV"

# Step 5: Wait and verify
echo "5. Verifying environment..."
sleep 60
STATUS=$(upsun environment:info -p "$PROJECT" -e "$ENV" status)
if [[ "$STATUS" == *"active"* ]]; then
    echo "Environment is active"
else
    echo "Environment status: $STATUS"
fi

# Step 6: Health check
ENV_URL=$(upsun environment:url -p "$PROJECT" -e "$ENV" --primary --pipe)
echo "Environment URL: $ENV_URL"
curl -Is "$ENV_URL" | head -n 1

echo ""
echo "Restore complete at $(date)"
echo "Backup restored: $BACKUP_ID"
echo "Safety backup: $PRE_RESTORE_ID (keep for rollback)"
