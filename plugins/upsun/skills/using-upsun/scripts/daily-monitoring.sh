#!/bin/bash
# Daily monitoring check for an Upsun environment
# Prints warnings when thresholds are exceeded.
PROJECT="${1:-abc123}"
ENV="${2:-production}"

# CPU check
CPU=$(upsun cpu -p $PROJECT -e $ENV --start "-1 hour" 2>&1 | grep -oP '\d+(?=%)' | tail -n 1)
if [ -n "$CPU" ] && [ "$CPU" -gt 80 ]; then
    echo "High CPU: ${CPU}%"
fi

# Memory check
MEM=$(upsun memory -p $PROJECT -e $ENV --start "-1 hour" 2>&1 | grep -oP '\d+(?=%)' | tail -n 1)
if [ -n "$MEM" ] && [ "$MEM" -gt 85 ]; then
    echo "High Memory: ${MEM}%"
fi

# Disk check
DISK=$(upsun disk -p $PROJECT -e $ENV 2>&1 | grep -oP '\d+(?=%)' | tail -n 1)
if [ -n "$DISK" ] && [ "$DISK" -gt 80 ]; then
    echo "High Disk Usage: ${DISK}%"
fi

# Error check
ERROR_COUNT=$(upsun logs -p $PROJECT -e $ENV --type error --lines 100 2>&1 | grep -c "ERROR")
if [ "$ERROR_COUNT" -gt 10 ]; then
    echo "High error count: $ERROR_COUNT errors in last 100 log lines"
fi
