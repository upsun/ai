# Database and Service Operations

Complete guide to working with databases and services on Upsun including PostgreSQL, MySQL, MongoDB, Redis, and Valkey operations.

## Overview

Upsun supports multiple database and service types. Each service can be accessed through relationships, tunnels, or CLI tools.

**Supported Services:**
- **Databases**: PostgreSQL, MySQL, MariaDB, MongoDB
- **Cache**: Redis, Valkey
- **Search**: Elasticsearch, Solr
- **Message Queues**: RabbitMQ, Kafka

## Service Relationships

### View Environment Relationships

List all service relationships for an environment:

```bash
upsun environment:relationships -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example output:**
```json
{
  "database": [
    {
      "host": "database.internal",
      "port": 5432,
      "scheme": "pgsql",
      "username": "main",
      "password": "main",
      "path": "main"
    }
  ],
  "redis": [
    {
      "host": "redis.internal",
      "port": 6379,
      "scheme": "redis"
    }
  ]
}
```

**Use cases:**
- Configure application database connections
- Verify service availability
- Troubleshoot connection issues
- Document service endpoints

## Database Operations

### Create Database Dump

Export database to local file:

```bash
upsun db:dump -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Common options:**
- `--gzip` - Compress output with gzip
- `--file FILENAME` - Save to specific file
- `--relationship NAME` - Specify relationship name
- `--stdout` - Output to stdout

**Examples:**

**Basic PostgreSQL dump:**
```bash
upsun db:dump -p abc123 -e production
```

**Compressed dump:**
```bash
upsun db:dump -p abc123 -e production --gzip --file production-dump.sql.gz
```

**Specific relationship:**
```bash
upsun db:dump -p abc123 -e production --relationship reports_db --file reports.sql
```

**Dump to stdout (for piping):**
```bash
upsun db:dump -p abc123 -e production --stdout | gzip > backup-$(date +%Y%m%d).sql.gz
```

### Run SQL Queries

Execute SQL directly on remote database:

```bash
upsun db:sql -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Interactive SQL session:**
```bash
upsun sql -p abc123 -e production
# Enters PostgreSQL/MySQL shell
```

**Execute single query:**
```bash
upsun sql -p abc123 -e production -- -c "SELECT COUNT(*) FROM users;"
```

**Execute SQL file:**
```bash
upsun sql -p abc123 -e production < migration.sql
```

**Specific relationship:**
```bash
upsun sql -p abc123 -e production --relationship analytics_db
```

**Examples by database type:**

**PostgreSQL:**
```bash
# List tables
upsun sql -p abc123 -e production -- -c "\dt"

# Show table schema
upsun sql -p abc123 -e production -- -c "\d users"

# Run query
upsun sql -p abc123 -e production -- -c "SELECT email FROM users WHERE created_at > NOW() - INTERVAL '1 day';"
```

**MySQL:**
```bash
# List tables
upsun sql -p abc123 -e production -- -e "SHOW TABLES;"

# Describe table
upsun sql -p abc123 -e production -- -e "DESCRIBE users;"

# Run query
upsun sql -p abc123 -e production -- -e "SELECT COUNT(*) FROM orders WHERE status='pending';"
```

## MongoDB Operations

### MongoDB Shell

Access MongoDB shell:

```bash
upsun service:mongo:shell -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Aliases:** `mongo`, `service:mongo:shell`

**Example:**
```bash
upsun mongo -p abc123 -e production
```

**In shell:**
```javascript
// Show databases
show dbs

// Use database
use myapp

// Show collections
show collections

// Query documents
db.users.find({status: "active"}).limit(10)

// Count documents
db.orders.countDocuments({status: "pending"})
```

### MongoDB Dump

Create binary archive of MongoDB data:

```bash
upsun service:mongo:dump -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example:**
```bash
upsun mongodump -p abc123 -e production
```

**Options:**
- `--collection` - Dump specific collection
- `--gzip` - Compress output
- `--directory DIR` - Output directory

**Dump specific collection:**
```bash
upsun mongodump -p abc123 -e production --collection users --gzip
```

### MongoDB Export

Export MongoDB data to JSON/CSV:

```bash
upsun service:mongo:export -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example - Export to JSON:**
```bash
upsun mongoexport -p abc123 -e production --collection orders --out orders.json
```

**Export to CSV:**
```bash
upsun mongoexport -p abc123 -e production --collection users --type csv --fields name,email,created_at --out users.csv
```

### MongoDB Restore

Restore MongoDB from binary archive:

```bash
upsun service:mongo:restore -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example:**
```bash
upsun mongorestore -p abc123 -e staging < production-dump/
```

**⚠️ Warning:** This will overwrite existing data.

**Safe restore workflow:**
```bash
# 1. Create backup first
upsun backup:create -p abc123 -e staging

# 2. Restore MongoDB data
upsun mongorestore -p abc123 -e staging < dump/

# 3. Verify data
upsun mongo -p abc123 -e staging
```

## Redis Operations

### Redis CLI Access

Access Redis command-line interface:

```bash
upsun service:redis-cli -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Alias:** `redis`

**Example:**
```bash
upsun redis -p abc123 -e production
```

**Common Redis commands:**
```bash
# Connect to Redis
upsun redis -p abc123 -e production

# In Redis CLI:
# Get all keys
KEYS *

# Get value
GET user:123:session

# Set value
SET test:key "test value"

# Check memory usage
INFO memory

# Flush all data (⚠️ destructive)
FLUSHALL
```

**Monitor Redis activity:**
```bash
upsun redis -p abc123 -e production
# In CLI:
MONITOR
```

**Check Redis stats:**
```bash
upsun redis -p abc123 -e production
# In CLI:
INFO stats
```

## Valkey Operations

### Valkey CLI Access

Access Valkey command-line interface (Redis-compatible):

```bash
upsun service:valkey-cli -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Alias:** `valkey`

**Example:**
```bash
upsun valkey -p abc123 -e production
```

**Valkey commands:** Same as Redis (fully compatible)

```bash
# Get key
GET session:abc123

# Set with expiration
SETEX cache:homepage 3600 "<html>..."

# Check key TTL
TTL cache:homepage

# View server info
INFO server
```

## Service Listing

### List All Services

View all services in an environment:

```bash
upsun service:list -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example:**
```bash
upsun services -p abc123 -e production
```

**Output:**
```
+----------+----------+---------+------+
| Name     | Type     | Size    | Disk |
+----------+----------+---------+------+
| database | postgres | S       | 2GB  |
| redis    | redis    | S       | 512MB|
| search   | elastic  | M       | 5GB  |
+----------+----------+---------+------+
```

## Tunneling to Services

### Create Service Tunnel

Create SSH tunnel for local access to services:

```bash
upsun tunnel:open -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example:**
```bash
upsun tunnel:open -p abc123 -e production
```

**What this does:**
- Creates SSH tunnels to all service relationships
- Assigns local ports
- Enables local database GUI tools
- Allows local development with remote data

**Example output:**
```
SSH tunnel opened to database at: 127.0.0.1:30000
SSH tunnel opened to redis at: 127.0.0.1:30001

Use the following connection details:
  database: postgresql://main:main@127.0.0.1:30000/main
  redis: redis://127.0.0.1:30001
```

### Single Service Tunnel

Open tunnel to specific service:

```bash
upsun tunnel:single RELATIONSHIP -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example:**
```bash
upsun tunnel:single database -p abc123 -e production
```

**Use with local tools:**
```bash
# Open tunnel
upsun tunnel:single database -p abc123 -e production

# In another terminal, connect with psql
psql postgresql://main:main@127.0.0.1:30000/main

# Or with GUI tools like pgAdmin, TablePlus, etc.
```

### List Active Tunnels

View currently open tunnels:

```bash
upsun tunnel:list -p PROJECT_ID -e ENVIRONMENT_NAME
```

**View tunnel connection info:**
```bash
upsun tunnel:info -p PROJECT_ID -e ENVIRONMENT_NAME
```

### Close Tunnels

Close all tunnels for an environment:

```bash
upsun tunnel:close -p PROJECT_ID -e ENVIRONMENT_NAME
```

## Database Migration Workflows

### Safe Migration Pattern

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"

echo "Starting database migration..."

# 1. Create pre-migration backup
echo "1. Creating backup..."
upsun backup:create -p $PROJECT -e $ENV --live

# 2. Verify backup
sleep 30
BACKUP_ID=$(upsun backup:list -p $PROJECT -e $ENV --limit 1 --pipe | head -n 1)
echo "Backup created: $BACKUP_ID"

# 3. Run migration
echo "2. Running migration..."
upsun ssh -p $PROJECT -e $ENV -- "cd /app && php artisan migrate --force"

# 4. Verify migration
echo "3. Verifying migration..."
upsun sql -p $PROJECT -e $ENV -- -c "SELECT version FROM migrations ORDER BY version DESC LIMIT 5;"

# 5. Test application
echo "4. Testing application..."
ENV_URL=$(upsun environment:url -p $PROJECT -e $ENV --primary --pipe)
HTTP_STATUS=$(curl -Is "$ENV_URL" | grep HTTP | head -n 1)
echo "HTTP Status: $HTTP_STATUS"

if [[ "$HTTP_STATUS" == *"200"* ]] || [[ "$HTTP_STATUS" == *"301"* ]]; then
    echo "✅ Migration successful"
else
    echo "❌ Migration may have issues - check logs"
    echo "Rollback available with: upsun backup:restore $BACKUP_ID -p $PROJECT -e $ENV"
    exit 1
fi
```

### Test Migrations on Staging

```bash
# 1. Sync production data to staging
upsun sync -p abc123 -e staging --data

# 2. Run migration on staging
upsun ssh -p abc123 -e staging -- "cd /app && npm run migrate"

# 3. Test on staging
upsun environment:url -p abc123 -e staging --primary --browser

# 4. If successful, run on production
upsun ssh -p abc123 -e production -- "cd /app && npm run migrate"
```

## Data Import/Export Workflows

### Export Production Data

```bash
#!/bin/bash
PROJECT="abc123"
DATE=$(date +%Y%m%d)

# PostgreSQL dump
upsun db:dump -p $PROJECT -e production --gzip --file "production-db-$DATE.sql.gz"

# MongoDB dump
upsun mongodump -p $PROJECT -e production --gzip --out "production-mongo-$DATE/"

echo "✅ Exports complete:"
echo "  - production-db-$DATE.sql.gz"
echo "  - production-mongo-$DATE/"
```

### Import to Staging

```bash
#!/bin/bash
PROJECT="abc123"
DUMP_FILE="production-db-20250107.sql.gz"

# 1. Backup staging first
upsun backup:create -p $PROJECT -e staging

# 2. Import to staging via tunnel
upsun tunnel:single database -p $PROJECT -e staging &
TUNNEL_PID=$!
sleep 5

# 3. Import data
gunzip < $DUMP_FILE | psql postgresql://main:main@127.0.0.1:30000/main

# 4. Close tunnel
kill $TUNNEL_PID

# 5. Verify import
upsun sql -p $PROJECT -e staging -- -c "SELECT COUNT(*) FROM users;"
```

## Best Practices

### Database Security

- Never commit credentials to Git
- Use environment variables for connections
- Limit direct database access
- Use read-only users for reporting
- Regularly rotate passwords

### Performance

- Index frequently queried fields
- Monitor slow queries
- Use connection pooling
- Implement caching (Redis/Valkey)
- Regular VACUUM (PostgreSQL)

### Backup Before Changes

Always backup before:
- Schema changes
- Large data imports
- Bulk deletions
- Migration scripts

### Testing

- Test migrations on staging first
- Verify data integrity after restore
- Test rollback procedures
- Document rollback steps

## Related Commands

**Backups:**
- `backup:create` - Backup including databases
- `backup:restore` - Restore databases
- See [backups.md](backups.md)

**Development:**
- `environment:ssh` - SSH access for database tools
- `tunnel:open` - Local database access
- See [development-tools.md](development-tools.md)

**Monitoring:**
- `environment:logs` - Application database logs
- `metrics:disk-usage` - Database disk usage
- See [resources-scaling.md](resources-scaling.md)

## Troubleshooting

**Cannot connect to database:**
- Check service is running: `service:list`
- Verify relationships: `environment:relationships`
- Check for incomplete activities
- Try tunnel for diagnosis

**Slow queries:**
- Check database metrics
- Review query logs
- Check for missing indexes
- Consider resource scaling

**Dump fails:**
- Check disk space
- Verify database accessibility
- Try smaller dumps (per-table)
- Use compressed dumps

**Import fails:**
- Check data format compatibility
- Verify database version matching
- Check for foreign key constraints
- Review import logs

For more troubleshooting, see [troubleshooting.md](troubleshooting.md).
