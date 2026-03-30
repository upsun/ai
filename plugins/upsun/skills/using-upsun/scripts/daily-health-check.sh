#!/bin/bash
# Daily health check: CPU, memory, disk, resources, autoscaling, and recent activities.
# Usage: ./daily-health-check.sh <PROJECT_ID> <ENVIRONMENT>
# Example: ./daily-health-check.sh abc123 production

set -euo pipefail

PROJECT="${1:?Usage: $0 <PROJECT_ID> <ENVIRONMENT>}"
ENV="${2:?Usage: $0 <PROJECT_ID> <ENVIRONMENT>}"

echo "=== Daily Health Check: $ENV ==="
echo "Date: $(date)"

echo "\n--- CPU (last 24h) ---"
upsun cpu -p "$PROJECT" -e "$ENV" --start "-24 hours" | tail -n 5

echo "\n--- Memory (last 24h) ---"
upsun memory -p "$PROJECT" -e "$ENV" --start "-24 hours" | tail -n 5

echo "\n--- Disk Usage ---"
upsun disk -p "$PROJECT" -e "$ENV"

echo "\n--- Current Resources ---"
upsun resources -p "$PROJECT" -e "$ENV"

echo "\n--- Autoscaling ---"
upsun autoscaling -p "$PROJECT" -e "$ENV"

echo "\n--- Recent Activities ---"
upsun activity:list -p "$PROJECT" -e "$ENV" --limit 5
