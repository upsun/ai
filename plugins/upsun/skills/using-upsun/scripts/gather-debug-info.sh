#!/bin/bash
# Gather debug information for Upsun support tickets
PROJECT="$1"
ENV="${2:-production}"

if [ -z "$PROJECT" ]; then
    echo "Usage: $0 PROJECT_ID [ENVIRONMENT]"
    exit 1
fi

cat > debug-info.txt <<EOF
Upsun Debug Information
Generated: $(date)
Project: $PROJECT
Environment: $ENV

--- CLI Version ---
$(upsun --version)

--- Environment Info ---
$(upsun environment:info -p $PROJECT -e $ENV 2>&1)

--- Recent Activities ---
$(upsun activity:list -p $PROJECT -e $ENV --limit 10 2>&1)

--- Incomplete Activities ---
$(upsun activity:list -p $PROJECT -e $ENV -i 2>&1)

--- Resources ---
$(upsun resources -p $PROJECT -e $ENV 2>&1)

--- Services ---
$(upsun service:list -p $PROJECT -e $ENV 2>&1)

--- Recent Error Logs ---
$(upsun logs -p $PROJECT -e $ENV --type error --lines 50 2>&1)

--- Metrics ---
CPU: $(upsun cpu -p $PROJECT -e $ENV --start "-1 hour" 2>&1 | tail -n 5)
Memory: $(upsun memory -p $PROJECT -e $ENV --start "-1 hour" 2>&1 | tail -n 5)
Disk: $(upsun disk -p $PROJECT -e $ENV 2>&1)
EOF

echo "Debug information saved to debug-info.txt"
