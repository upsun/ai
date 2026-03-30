#!/bin/bash
# Import a database dump into a staging environment via SSH tunnel.
# Usage: ./import-db-to-staging.sh <PROJECT_ID> <DUMP_FILE>
# Example: ./import-db-to-staging.sh abc123 production-db-20250107.sql.gz

set -euo pipefail

PROJECT="${1:?Usage: $0 <PROJECT_ID> <DUMP_FILE>}"
DUMP_FILE="${2:?Usage: $0 <PROJECT_ID> <DUMP_FILE>}"

# 1. Backup staging first
echo "Backing up staging..."
upsun backup:create -p "$PROJECT" -e staging

# 2. Open tunnel
echo "Opening tunnel..."
upsun tunnel:single database -p "$PROJECT" -e staging &
TUNNEL_PID=$!
sleep 5

# 3. Import data
echo "Importing $DUMP_FILE..."
gunzip < "$DUMP_FILE" | psql postgresql://main:main@127.0.0.1:30000/main

# 4. Close tunnel
kill $TUNNEL_PID

# 5. Verify import
echo "Verifying..."
upsun sql -p "$PROJECT" -e staging -- -c "SELECT COUNT(*) FROM users;"
echo "Import complete"
