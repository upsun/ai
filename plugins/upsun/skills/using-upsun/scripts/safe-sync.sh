#!/bin/bash
# Safely sync data from parent with backup
# Usage: safe-sync.sh PROJECT_ID ENVIRONMENT [--code] [--data] [--resources]
PROJECT="${1:?Usage: $0 PROJECT_ID ENVIRONMENT [--code] [--data] [--resources]}"
ENV="${2:?Usage: $0 PROJECT_ID ENVIRONMENT [--code] [--data] [--resources]}"
shift 2
SYNC_FLAGS="${@:---data}"

echo "Creating backup of $ENV before sync..."
upsun backup:create -p $PROJECT -e $ENV

echo "Verifying backup..."
upsun backup:list -p $PROJECT -e $ENV | head -n 5

echo "Syncing from parent with flags: $SYNC_FLAGS"
upsun sync -p $PROJECT -e $ENV $SYNC_FLAGS

echo "Verifying environment status..."
upsun environment:info -p $PROJECT -e $ENV status
