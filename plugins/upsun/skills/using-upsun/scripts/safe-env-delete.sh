#!/bin/bash
# Safely delete an environment with backup
# Usage: safe-env-delete.sh PROJECT_ID ENVIRONMENT
PROJECT="${1:?Usage: $0 PROJECT_ID ENVIRONMENT}"
ENV="${2:?Usage: $0 PROJECT_ID ENVIRONMENT}"

echo "Creating backup of $ENV..."
upsun backup:create -p $PROJECT -e $ENV

echo "Verifying backup..."
upsun backup:list -p $PROJECT -e $ENV

echo "Deleting environment $ENV..."
upsun environment:delete -p $PROJECT -e $ENV
