#!/bin/bash
# Run diagnostics on an Upsun environment
PROJECT="${1:-}"
ENV="${2:-production}"

if [ -z "$PROJECT" ]; then
    echo "Usage: $0 PROJECT_ID [ENVIRONMENT]"
    exit 1
fi

echo "=== Upsun Health Check ==="
echo "Project: $PROJECT"
echo "Environment: $ENV"
echo "Time: $(date)"

# Authentication
echo -e "\n--- Authentication ---"
if upsun auth:info --no-interaction >/dev/null 2>&1; then
    echo "Authenticated"
else
    echo "Not authenticated. Run: upsun auth:browser-login"
    exit 1
fi

# Environment status
echo -e "\n--- Environment Status ---"
STATUS=$(upsun environment:info -p $PROJECT -e $ENV status 2>&1)
if [ $? -eq 0 ]; then
    echo "Status: $STATUS"
else
    echo "Cannot access environment"
    echo "$STATUS"
    exit 1
fi

# Incomplete activities
echo -e "\n--- Incomplete Activities ---"
INCOMPLETE=$(upsun activity:list -p $PROJECT -e $ENV -i --pipe 2>&1 | wc -l)
if [ $INCOMPLETE -gt 0 ]; then
    echo "$INCOMPLETE incomplete activities"
    upsun activity:list -p $PROJECT -e $ENV -i --limit 5
else
    echo "No incomplete activities"
fi

# Recent errors
echo -e "\n--- Recent Error Logs ---"
upsun logs -p $PROJECT -e $ENV --type error --lines 10 2>&1 | head -n 15

# Resources
echo -e "\n--- Resources ---"
upsun resources -p $PROJECT -e $ENV 2>&1 | head -n 20

# Metrics
echo -e "\n--- Recent Metrics ---"
echo "CPU (last hour):"
upsun cpu -p $PROJECT -e $ENV --start "-1 hour" 2>&1 | tail -n 3
echo "Memory (last hour):"
upsun memory -p $PROJECT -e $ENV --start "-1 hour" 2>&1 | tail -n 3

echo -e "\n=== Health Check Complete ==="
