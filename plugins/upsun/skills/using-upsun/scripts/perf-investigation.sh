#!/bin/bash
# Investigate performance issues on an Upsun environment
# Usage: perf-investigation.sh PROJECT_ID ENVIRONMENT
PROJECT="${1:?Usage: $0 PROJECT_ID ENVIRONMENT}"
ENV="${2:-production}"

echo "=== Performance Investigation ==="

echo "\n--- CPU Usage (last hour) ---"
upsun cpu -p $PROJECT -e $ENV --start "-1 hour"

echo "\n--- Memory Usage (last hour) ---"
upsun memory -p $PROJECT -e $ENV --start "-1 hour"

echo "\n--- Slow Access Logs ---"
upsun logs -p $PROJECT -e $ENV --type access --lines 1000 | \
  grep -E "time:[0-9]{4,}" | \
  head -n 20

echo "\n--- Recent Errors ---"
upsun logs -p $PROJECT -e $ENV --type error --lines 100 | \
  grep -c "ERROR"
