#!/bin/bash
# Safe production deployment: checks for blockers, backs up, deploys, verifies.
# Usage: ./deploy-production.sh <PROJECT_ID> [STRATEGY]

PROJECT="${1:?Usage: $0 <PROJECT_ID> [STRATEGY]}"
ENV="production"
STRATEGY="${2:-rolling}"

# 1. Verify authentication
upsun auth:info || exit 1

# 2. Check for incomplete activities
INCOMPLETE=$(upsun activity:list -p "$PROJECT" -e "$ENV" -i --pipe | wc -l)
if [ "$INCOMPLETE" -gt 0 ]; then
    echo "ERROR: Incomplete activities found. Resolve before deploying."
    upsun activity:list -p "$PROJECT" -e "$ENV" -i
    exit 1
fi

# 3. Create backup
echo "Creating production backup..."
upsun backup:create -p "$PROJECT" -e "$ENV"
sleep 10

# 4. Deploy
echo "Deploying to production (strategy: $STRATEGY)..."
upsun deploy -p "$PROJECT" -e "$ENV" --strategy "$STRATEGY"

# 5. Monitor
ACTIVITY_ID=$(upsun activity:list -p "$PROJECT" -e "$ENV" --limit 1 --pipe | head -n 1)
echo "Monitoring deployment: $ACTIVITY_ID"
upsun activity:log "$ACTIVITY_ID" -p "$PROJECT"

# 6. Verify
upsun activity:get "$ACTIVITY_ID" -p "$PROJECT" | grep -q "success"
if [ $? -eq 0 ]; then
    echo "Deployment successful"
else
    echo "Deployment failed"
    exit 1
fi

# 7. Health check
echo "Running health check..."
upsun environment:url -p "$PROJECT" -e "$ENV" --primary
