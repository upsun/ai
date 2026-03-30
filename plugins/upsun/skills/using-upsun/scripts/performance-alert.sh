#!/bin/bash
# Check CPU, memory, and disk against thresholds and alert if exceeded.
# Usage: ./performance-alert.sh <PROJECT_ID> <ENVIRONMENT> [CPU_THRESH] [MEM_THRESH] [DISK_THRESH]
# Example: ./performance-alert.sh abc123 production 90 90 85

set -euo pipefail

PROJECT="${1:?Usage: $0 <PROJECT_ID> <ENVIRONMENT> [CPU_THRESH] [MEM_THRESH] [DISK_THRESH]}"
ENV="${2:?Usage: $0 <PROJECT_ID> <ENVIRONMENT> [CPU_THRESH] [MEM_THRESH] [DISK_THRESH]}"
CPU_THRESHOLD="${3:-90}"
MEMORY_THRESHOLD="${4:-90}"
DISK_THRESHOLD="${5:-85}"

# Check CPU
CPU_USAGE=$(upsun cpu -p "$PROJECT" -e "$ENV" --start "-5 minutes" | grep -oP '\d+(?=%)' | tail -n 1)
if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
    echo "ALERT: High CPU usage: ${CPU_USAGE}%"
fi

# Check Memory
MEM_USAGE=$(upsun memory -p "$PROJECT" -e "$ENV" --start "-5 minutes" | grep -oP '\d+(?=%)' | tail -n 1)
if [ "$MEM_USAGE" -gt "$MEMORY_THRESHOLD" ]; then
    echo "ALERT: High memory usage: ${MEM_USAGE}%"
fi

# Check Disk
DISK_USAGE=$(upsun disk -p "$PROJECT" -e "$ENV" | grep -oP '\d+(?=%)' | tail -n 1)
if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo "ALERT: High disk usage: ${DISK_USAGE}%"
fi
