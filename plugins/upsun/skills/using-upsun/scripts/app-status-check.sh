#!/bin/bash
# Check application status on an Upsun environment
# Usage: app-status-check.sh PROJECT_ID ENVIRONMENT
PROJECT="${1:?Usage: $0 PROJECT_ID ENVIRONMENT}"
ENV="${2:-production}"

echo "=== Application Status ==="

echo "\n--- System ---"
upsun ssh -p $PROJECT -e $ENV -- "uname -a"

echo "\n--- PHP Version ---"
upsun ssh -p $PROJECT -e $ENV -- "php -v"

echo "\n--- Disk Usage ---"
upsun ssh -p $PROJECT -e $ENV -- "df -h"

echo "\n--- Memory ---"
upsun ssh -p $PROJECT -e $ENV -- "free -h"

echo "\n--- Processes ---"
upsun ssh -p $PROJECT -e $ENV -- "ps aux | head -n 10"
