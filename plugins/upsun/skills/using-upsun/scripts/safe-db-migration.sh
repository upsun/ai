#!/bin/bash
# Safe database migration with pre-migration backup and post-migration verification.
# Usage: ./safe-db-migration.sh <PROJECT_ID> <ENVIRONMENT> <MIGRATION_COMMAND>
# Example: ./safe-db-migration.sh abc123 production "cd /app && php artisan migrate --force"

set -euo pipefail

PROJECT="${1:?Usage: $0 <PROJECT_ID> <ENVIRONMENT> <MIGRATION_COMMAND>}"
ENV="${2:?Usage: $0 <PROJECT_ID> <ENVIRONMENT> <MIGRATION_COMMAND>}"
MIGRATION_CMD="${3:?Usage: $0 <PROJECT_ID> <ENVIRONMENT> <MIGRATION_COMMAND>}"

echo "Starting database migration on $ENV..."

# 1. Create pre-migration backup
echo "1. Creating backup..."
upsun backup:create -p "$PROJECT" -e "$ENV" --live

sleep 30
BACKUP_ID=$(upsun backup:list -p "$PROJECT" -e "$ENV" --limit 1 --pipe | head -n 1)
echo "Backup created: $BACKUP_ID"

# 2. Run migration
echo "2. Running migration..."
upsun ssh -p "$PROJECT" -e "$ENV" -- "$MIGRATION_CMD"

# 3. Verify migration
echo "3. Verifying migration..."
upsun sql -p "$PROJECT" -e "$ENV" -- -c "SELECT version FROM migrations ORDER BY version DESC LIMIT 5;"

# 4. Test application
echo "4. Testing application..."
ENV_URL=$(upsun environment:url -p "$PROJECT" -e "$ENV" --primary --pipe)
HTTP_STATUS=$(curl -Is "$ENV_URL" | grep HTTP | head -n 1)
echo "HTTP Status: $HTTP_STATUS"

if [[ "$HTTP_STATUS" == *"200"* ]] || [[ "$HTTP_STATUS" == *"301"* ]]; then
    echo "Migration successful"
else
    echo "Migration may have issues, check logs"
    echo "Rollback available with: upsun backup:restore $BACKUP_ID -p $PROJECT -e $ENV"
    exit 1
fi
