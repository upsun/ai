#!/bin/bash
# Create a new Upsun project, clone it, initialize config, add a user, and create staging
# Usage: ORG=my-company TITLE="My App" REGION=us-east-1 bash new-project-setup.sh

ORG="${ORG:?Set ORG}"
TITLE="${TITLE:?Set TITLE}"
REGION="${REGION:-us-east-1}"

echo "Creating new Upsun project..."

PROJECT_ID=$(upsun create \
  --title "$TITLE" \
  --region "$REGION" \
  --org "$ORG" \
  --pipe)

echo "Project created: $PROJECT_ID"

upsun get "$PROJECT_ID" ~/projects/new-app
cd ~/projects/new-app
upsun init

# Optional: add a user (set DEV_EMAIL to enable)
if [ -n "$DEV_EMAIL" ]; then
  upsun user:add "$DEV_EMAIL" -p "$PROJECT_ID" --role contributor
fi

upsun environment:branch staging -p "$PROJECT_ID"

echo "Project setup complete"
echo "Project ID: $PROJECT_ID"
echo "Local path: ~/projects/new-app"
