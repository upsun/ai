#!/bin/bash
# Debug a production issue on an Upsun environment
# Usage: debug-production.sh PROJECT_ID ENVIRONMENT
PROJECT="${1:?Usage: $0 PROJECT_ID ENVIRONMENT}"
ENV="${2:-production}"

echo "=== Debugging Production Issue ==="

echo "\n--- Recent Error Logs ---"
upsun logs -p $PROJECT -e $ENV --type error --lines 50

echo "\n--- Application Status ---"
upsun ssh -p $PROJECT -e $ENV -- "cd /app && php artisan --version"

echo "\n--- Database Connection ---"
upsun ssh -p $PROJECT -e $ENV -- "psql -c 'SELECT 1;'" >/dev/null 2>&1 && echo "Connected" || echo "Failed"

echo "\n--- Disk Space ---"
upsun ssh -p $PROJECT -e $ENV -- "df -h | grep /app"

echo "\n--- Recent Activities ---"
upsun activity:list -p $PROJECT -e $ENV --limit 5
