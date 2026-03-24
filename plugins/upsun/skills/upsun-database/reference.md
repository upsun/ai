# Database and Service Operations — Reference

Complete guide to working with databases and services on Upsun including PostgreSQL, MySQL, MongoDB, Redis, and Valkey.

## Overview

**Supported services:**
- Databases: PostgreSQL, MySQL, MariaDB, MongoDB
- Cache: Redis, Valkey
- Search: Elasticsearch, Solr
- Message queues: RabbitMQ, Kafka

## Service Relationships

### View Environment Relationships

```bash
upsun environment:relationships -p PROJECT_ID -e ENVIRONMENT_NAME
```

Example output:
```json
{
  "database": [{ "host": "database.internal", "port": 5432, "scheme": "pgsql", "username": "main", "password": "main", "path": "main" }],
  "redis": [{ "host": "redis.internal", "port": 6379, "scheme": "redis" }]
}
```

## Database Operations

### Create Database Dump

```bash
upsun db:dump -p PROJECT_ID -e ENVIRONMENT_NAME

# Compressed dump
upsun db:dump -p abc123 -e production --gzip --file production-dump.sql.gz

# Specific relationship
upsun db:dump -p abc123 -e production --relationship reports_db --file reports.sql

# Dump to stdout (for piping)
upsun db:dump -p abc123 -e production --stdout | gzip > backup-$(date +%Y%m%d).sql.gz
```

**Options:** `--gzip`, `--file FILENAME`, `--relationship NAME`, `--stdout`

### Run SQL Queries

```bash
upsun db:sql -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: sql

# Interactive shell
upsun sql -p abc123 -e production

# Single query
upsun sql -p abc123 -e production -- -c "SELECT COUNT(*) FROM users;"

# Execute SQL file
upsun sql -p abc123 -e production < migration.sql

# Specific relationship
upsun sql -p abc123 -e production --relationship analytics_db
```

**PostgreSQL examples:**
```bash
# List tables
upsun sql -p abc123 -e production -- -c "\dt"

# Show table schema
upsun sql -p abc123 -e production -- -c "\d users"

# Run query
upsun sql -p abc123 -e production -- -c "SELECT email FROM users WHERE created_at > NOW() - INTERVAL '1 day';"
```

**MySQL examples:**
```bash
upsun sql -p abc123 -e production -- -e "SHOW TABLES;"
upsun sql -p abc123 -e production -- -e "DESCRIBE users;"
upsun sql -p abc123 -e production -- -e "SELECT COUNT(*) FROM orders WHERE status='pending';"
```

## MongoDB Operations

### MongoDB Shell

```bash
upsun service:mongo:shell -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: mongo

upsun mongo -p abc123 -e production
```

In shell:
```javascript
show dbs
use myapp
show collections
db.users.find({status: "active"}).limit(10)
db.orders.countDocuments({status: "pending"})
```

### MongoDB Dump

```bash
upsun service:mongo:dump -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: mongodump

upsun mongodump -p abc123 -e production
upsun mongodump -p abc123 -e production --collection users --gzip
```

Options: `--collection`, `--gzip`, `--directory DIR`

### MongoDB Export

```bash
upsun service:mongo:export -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: mongoexport

# Export to JSON
upsun mongoexport -p abc123 -e production --collection orders --out orders.json

# Export to CSV
upsun mongoexport -p abc123 -e production --collection users --type csv --fields name,email,created_at --out users.csv
```

### MongoDB Restore

```bash
upsun service:mongo:restore -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: mongorestore

# Safe restore workflow
upsun backup:create -p abc123 -e staging
upsun mongorestore -p abc123 -e staging < dump/
upsun mongo -p abc123 -e staging   # verify
```

## Redis Operations

### Redis CLI

```bash
upsun service:redis-cli -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: redis

upsun redis -p abc123 -e production
```

Common Redis commands:
```bash
KEYS *                         # Get all keys
GET user:123:session           # Get value
SET test:key "test value"      # Set value
INFO memory                    # Check memory usage
FLUSHALL                       # Flush all data (DESTRUCTIVE)
MONITOR                        # Monitor activity
INFO stats                     # Check stats
```

## Valkey Operations

### Valkey CLI

```bash
upsun service:valkey-cli -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: valkey

upsun valkey -p abc123 -e production
```

Commands are identical to Redis (fully compatible):
```bash
GET session:abc123
SETEX cache:homepage 3600 "<html>..."
TTL cache:homepage
INFO server
```

## Service Listing

```bash
upsun service:list -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: services

upsun services -p abc123 -e production
```

Example output:
```
+----------+----------+------+-------+
| Name     | Type     | Size | Disk  |
+----------+----------+------+-------+
| database | postgres | S    | 2GB   |
| redis    | redis    | S    | 512MB |
+----------+----------+------+-------+
```

## Tunneling to Services

### Open All Tunnels

```bash
upsun tunnel:open -p PROJECT_ID -e ENVIRONMENT_NAME

upsun tunnel:open -p abc123 -e production
```

Example output:
```
SSH tunnel opened to database at: 127.0.0.1:30000
SSH tunnel opened to redis at: 127.0.0.1:30001

Use the following connection details:
  database: postgresql://main:main@127.0.0.1:30000/main
  redis: redis://127.0.0.1:30001
```

### Single Service Tunnel

```bash
upsun tunnel:single RELATIONSHIP -p PROJECT_ID -e ENVIRONMENT_NAME

upsun tunnel:single database -p abc123 -e production
```

### List and Close Tunnels

```bash
upsun tunnel:list -p PROJECT_ID -e ENV           # list
upsun tunnel:info -p PROJECT_ID -e ENV           # connection details
upsun tunnel:close -p PROJECT_ID -e ENV          # close all
```

### Using Tunnels with Local Tools

```bash
# Open tunnel
upsun tunnel:single database -p abc123 -e production
# Connect pgAdmin / TablePlus: host=127.0.0.1, port=30000, user=main, pass=main, db=main

# PostgreSQL CLI
psql postgresql://main:main@127.0.0.1:30000/main

# Redis CLI
upsun tunnel:single redis -p abc123 -e production
redis-cli -p 30001

# MongoDB
upsun tunnel:single mongodb -p abc123 -e production
mongosh "mongodb://127.0.0.1:30002/main"
```

**With local development:**
```bash
upsun tunnel:open -p abc123 -e production
# Update local .env:
DATABASE_URL=postgresql://main:main@127.0.0.1:30000/main
REDIS_URL=redis://127.0.0.1:30001
npm run dev
```

## Database Migration Workflow

### Safe Migration Pattern

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"

echo "Creating pre-migration backup..."
upsun backup:create -p $PROJECT -e $ENV --live

sleep 30
BACKUP_ID=$(upsun backup:list -p $PROJECT -e $ENV --limit 1 --pipe | head -n 1)
echo "Backup: $BACKUP_ID"

echo "Running migration..."
upsun ssh -p $PROJECT -e $ENV -- "cd /app && php artisan migrate --force"

echo "Verifying..."
upsun sql -p $PROJECT -e $ENV -- -c "SELECT version FROM migrations ORDER BY version DESC LIMIT 5;"

ENV_URL=$(upsun environment:url -p $PROJECT -e $ENV --primary --pipe)
HTTP_STATUS=$(curl -Is "$ENV_URL" | grep HTTP | head -n 1)
echo "HTTP Status: $HTTP_STATUS"

if [[ "$HTTP_STATUS" == *"200"* ]] || [[ "$HTTP_STATUS" == *"301"* ]]; then
    echo "Migration successful"
else
    echo "Migration may have issues"
    echo "Rollback: upsun backup:restore $BACKUP_ID -p $PROJECT -e $ENV"
    exit 1
fi
```

### Test on Staging First

```bash
upsun sync -p abc123 -e staging --data
upsun ssh -p abc123 -e staging -- "cd /app && npm run migrate"
upsun environment:url -p abc123 -e staging --primary
# If successful:
upsun ssh -p abc123 -e production -- "cd /app && npm run migrate"
```

## Data Import/Export Workflows

### Export Production Data

```bash
#!/bin/bash
PROJECT="abc123"
DATE=$(date +%Y%m%d)

upsun db:dump -p $PROJECT -e production --gzip --file "production-db-$DATE.sql.gz"
upsun mongodump -p $PROJECT -e production --gzip --out "production-mongo-$DATE/"
```

### Import to Staging via Tunnel

```bash
#!/bin/bash
PROJECT="abc123"
DUMP_FILE="production-db-20250107.sql.gz"

upsun backup:create -p $PROJECT -e staging

upsun tunnel:single database -p $PROJECT -e staging &
TUNNEL_PID=$!
sleep 5

gunzip < $DUMP_FILE | psql postgresql://main:main@127.0.0.1:30000/main

kill $TUNNEL_PID

upsun sql -p $PROJECT -e staging -- -c "SELECT COUNT(*) FROM users;"
```

## Troubleshooting

**Cannot connect to database:**
- Check service is running: `service:list`
- Verify relationships: `environment:relationships`
- Check for incomplete activities: `activity:list -i`
- Try tunnel for direct diagnosis

**Slow queries:**
- Check database metrics: `metrics:disk-usage`, `metrics:cpu`
- Identify slow queries via pg_stat_statements (PostgreSQL)
- Check for missing indexes
- Consider resource scaling: `resources:set --size database:L`

**Dump fails:**
- Check disk space: `upsun disk`
- Verify database is accessible
- Try smaller dumps (per-table)
- Use compressed dumps with `--gzip`

**Import fails:**
- Check data format compatibility
- Verify database version matching
- Check for foreign key constraints
- Review import logs
