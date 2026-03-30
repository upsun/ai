#!/bin/bash
# Set up local development with production data
# Usage: local-dev-with-prod-data.sh PROJECT_ID
PROJECT="${1:?Usage: $0 PROJECT_ID}"

echo "Dumping production database..."
upsun db:dump -p $PROJECT -e production --gzip --file prod-db.sql.gz

echo "Opening Redis tunnel..."
upsun tunnel:single redis -p $PROJECT -e production &
TUNNEL_PID=$!
sleep 5

echo "Starting local development..."
export DATABASE_FILE="prod-db.sql.gz"
export REDIS_URL="redis://127.0.0.1:30001"
npm run dev

# Cleanup
kill $TUNNEL_PID
