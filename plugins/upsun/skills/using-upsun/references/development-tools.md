# Development Tools

Complete guide to development and debugging tools including SSH access, tunnels, logs, and repository operations on Upsun.

## Overview

Upsun provides comprehensive tools for developers to debug, inspect, and interact with their applications and environments.

**Available Tools:**
- **SSH Access** - Direct shell access to environments
- **Tunnels** - Local access to remote services
- **Logs** - Application and service logs
- **Repository Operations** - Remote file inspection
- **File Transfer** - SCP for file operations
- **Mounts** - Persistent storage management
- **Operations** - Runtime operations

## SSH Access

### Connect via SSH

Access environment shell:

```bash
upsun environment:ssh -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Alias:** `ssh`

**Example:**
```bash
upsun ssh -p abc123 -e production
```

**Connect to specific app:**
```bash
upsun ssh -p abc123 -e production --app myapp
```

**Connect to worker:**
```bash
upsun ssh -p abc123 -e production --worker queue-worker
```

### Run Single Command

Execute command without interactive shell:

```bash
upsun ssh -p PROJECT_ID -e ENVIRONMENT_NAME -- COMMAND
```

**Examples:**

**Check PHP version:**
```bash
upsun ssh -p abc123 -e production -- php -v
```

**List files:**
```bash
upsun ssh -p abc123 -e production -- ls -la /app
```

**Check disk usage:**
```bash
upsun ssh -p abc123 -e production -- df -h
```

**Run application command:**
```bash
upsun ssh -p abc123 -e production -- "cd /app && npm run status"
```

**Database query:**
```bash
upsun ssh -p abc123 -e production -- "psql -c 'SELECT COUNT(*) FROM users;'"
```

### SSH Workflow Examples

**Check application status:**
```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"

echo "=== Application Status ==="

# System info
echo "\n--- System ---"
upsun ssh -p $PROJECT -e $ENV -- "uname -a"

# PHP version
echo "\n--- PHP Version ---"
upsun ssh -p $PROJECT -e $ENV -- "php -v"

# Disk usage
echo "\n--- Disk Usage ---"
upsun ssh -p $PROJECT -e $ENV -- "df -h"

# Memory usage
echo "\n--- Memory ---"
upsun ssh -p $PROJECT -e $ENV -- "free -h"

# Process list
echo "\n--- Processes ---"
upsun ssh -p $PROJECT -e $ENV -- "ps aux | head -n 10"
```

**Clear application cache:**
```bash
upsun ssh -p abc123 -e production -- "cd /app && php artisan cache:clear"
```

**Run database migration:**
```bash
upsun ssh -p abc123 -e staging -- "cd /app && npm run migrate"
```

## File Transfer

### SCP - Secure Copy

Transfer files to/from environments:

```bash
upsun environment:scp SOURCE DESTINATION
```

**Alias:** `scp`

**Download file from environment:**
```bash
upsun scp abc123-production:/app/storage/logs/app.log ./local-app.log
```

**Upload file to environment:**
```bash
upsun scp ./local-config.json abc123-production:/app/config/
```

**Download directory:**
```bash
upsun scp abc123-production:/app/public/uploads/ ./uploads/ -r
```

**Upload directory:**
```bash
upsun scp ./build/ abc123-production:/app/public/ -r
```

**Format:**
- Remote: `PROJECT_ID-ENVIRONMENT:/path`
- Local: `./path` or `/absolute/path`
- Use `-r` for directories

### Mount Operations

**Upload to mount:**
```bash
upsun mount:upload --mount /app/public/uploads --source ./local-uploads/
```

**Download from mount:**
```bash
upsun mount:download --mount /app/public/uploads --target ./downloaded-uploads/
```

**List mounts:**
```bash
upsun mount:list -p abc123 -e production
```

**Alias:** `mounts`

## Logs

### View Application Logs

Access environment logs:

```bash
upsun environment:logs -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Alias:** `log`

**Example:**
```bash
upsun logs -p abc123 -e production
```

### Tail Logs (Follow Mode)

Watch logs in real-time:

```bash
upsun logs -p abc123 -e production --tail
```

**Limit lines:**
```bash
upsun logs -p abc123 -e production --tail --lines 100
```

### Filter Logs

**By application:**
```bash
upsun logs -p abc123 -e production --app myapp
```

**By service:**
```bash
upsun logs -p abc123 -e production --service database
```

**Multiple filters:**
```bash
upsun logs -p abc123 -e production --app api --tail --lines 50
```

### Log Types

Different log streams available:

```bash
# Application logs
upsun logs -p abc123 -e production --type app

# Access logs (HTTP requests)
upsun logs -p abc123 -e production --type access

# Error logs
upsun logs -p abc123 -e production --type error

# Deploy logs
upsun logs -p abc123 -e production --type deploy
```

### Log Analysis Examples

**Find errors in last hour:**
```bash
upsun logs -p abc123 -e production --tail --lines 1000 | grep -i error
```

**Count 404 errors:**
```bash
upsun logs -p abc123 -e production --type access | grep " 404 " | wc -l
```

**Find slow requests:**
```bash
upsun logs -p abc123 -e production --type access | grep -E "time:[0-9]{4,}"
```

**Monitor specific endpoint:**
```bash
upsun logs -p abc123 -e production --tail | grep "/api/users"
```

## Tunnels

### Open All Tunnels

Create SSH tunnels to all services:

```bash
upsun tunnel:open -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example:**
```bash
upsun tunnel:open -p abc123 -e production
```

**Output:**
```
SSH tunnel opened to database at: 127.0.0.1:30000
SSH tunnel opened to redis at: 127.0.0.1:30001
SSH tunnel opened to elasticsearch at: 127.0.0.1:30002

Connection details:
  database: postgresql://main:main@127.0.0.1:30000/main
  redis: redis://127.0.0.1:30001
  elasticsearch: http://127.0.0.1:30002
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

### List Active Tunnels

View currently open tunnels:

```bash
upsun tunnel:list -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Alias:** `tunnels`

**Example:**
```bash
upsun tunnels -p abc123 -e production
```

### View Tunnel Info

Get connection information for tunnels:

```bash
upsun tunnel:info -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example:**
```bash
upsun tunnel:info -p abc123 -e production
```

### Close Tunnels

Close all tunnels for environment:

```bash
upsun tunnel:close -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example:**
```bash
upsun tunnel:close -p abc123 -e production
```

### Using Tunnels

**With database GUI tools:**

```bash
# 1. Open tunnel
upsun tunnel:single database -p abc123 -e production

# 2. Connect with GUI tool (TablePlus, pgAdmin, etc.)
# Host: 127.0.0.1
# Port: 30000 (from tunnel output)
# User: main
# Password: main
# Database: main
```

**With local development:**

```bash
# 1. Open tunnels
upsun tunnel:open -p abc123 -e production

# 2. Update local .env
DATABASE_URL=postgresql://main:main@127.0.0.1:30000/main
REDIS_URL=redis://127.0.0.1:30001

# 3. Run local app with production data
npm run dev
```

**With CLI tools:**

```bash
# PostgreSQL
upsun tunnel:single database -p abc123 -e production
psql postgresql://main:main@127.0.0.1:30000/main

# Redis
upsun tunnel:single redis -p abc123 -e production
redis-cli -p 30001

# MongoDB
upsun tunnel:single mongodb -p abc123 -e production
mongosh "mongodb://127.0.0.1:30002/main"
```

## Repository Operations

### Read Repository File

View file contents from repository:

```bash
upsun repo:read PATH -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Alias:** `read`

**Example:**
```bash
upsun read .upsun/config.yaml -p abc123 -e production
```

### List Repository Files

List files in repository directory:

```bash
upsun repo:ls PATH -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example:**
```bash
upsun repo:ls /app/config -p abc123 -e production
```

### Cat Repository File

Output file contents (cat):

```bash
upsun repo:cat FILE -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example:**
```bash
upsun repo:cat composer.json -p abc123 -e production
```

**Pipe to local file:**
```bash
upsun repo:cat .upsun/config.yaml -p abc123 -e production > local-config.yaml
```

## Runtime Operations

### List Available Operations

View available runtime operations:

```bash
upsun operation:list -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Alias:** `ops`

**Example:**
```bash
upsun ops -p abc123 -e production
```

**Common operations:**
- `clear:cache` - Clear application cache
- `clear:tmp` - Clear temporary files
- `reindex` - Rebuild search indexes
- `warmup` - Warm up caches

### Run Operation

Execute a runtime operation:

```bash
upsun operation:run OPERATION -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example:**
```bash
upsun operation:run clear:cache -p abc123 -e production
```

**With parameters:**
```bash
upsun operation:run reindex -p abc123 -e production --full
```

## Xdebug Tunnel

### Enable Xdebug

Open tunnel for PHP Xdebug:

```bash
upsun environment:xdebug -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Alias:** `xdebug`

**Example:**
```bash
upsun xdebug -p abc123 -e staging
```

**Setup:**
1. Run `upsun xdebug`
2. Configure IDE to listen on port 9000
3. Set breakpoints
4. Make HTTP request to trigger debug session

**PHPStorm configuration:**
- Server name: upsun
- Port: 9000
- IDE key: PHPSTORM
- Path mappings: /app -> local project path

## Drush (Drupal)

### Run Drush Command

Execute Drush commands on Drupal sites:

```bash
upsun environment:drush COMMAND -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Alias:** `drush`

**Examples:**

**Clear cache:**
```bash
upsun drush cr -p abc123 -e production
```

**Run updates:**
```bash
upsun drush updatedb -p abc123 -e production
```

**Export configuration:**
```bash
upsun drush config:export -p abc123 -e production
```

**User management:**
```bash
upsun drush user:create admin --mail="admin@example.com" -p abc123 -e production
```

## Local Project Detection

### Find Project Root

Locate local project root directory:

```bash
upsun local:dir
```

**Alias:** `dir`

**Use in scripts:**
```bash
PROJECT_ROOT=$(upsun dir)
cd $PROJECT_ROOT
```

## Development Workflows

### Debug Production Issue

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"

echo "=== Debugging Production Issue ==="

# 1. Check recent logs
echo "\n--- Recent Error Logs ---"
upsun logs -p $PROJECT -e $ENV --type error --lines 50

# 2. Check application status
echo "\n--- Application Status ---"
upsun ssh -p $PROJECT -e $ENV -- "cd /app && php artisan --version"

# 3. Check database connectivity
echo "\n--- Database Connection ---"
upsun ssh -p $PROJECT -e $ENV -- "psql -c 'SELECT 1;'" >/dev/null 2>&1 && echo "✅ Connected" || echo "❌ Failed"

# 4. Check disk space
echo "\n--- Disk Space ---"
upsun ssh -p $PROJECT -e $ENV -- "df -h | grep /app"

# 5. Check recent activities
echo "\n--- Recent Activities ---"
upsun activity:list -p $PROJECT -e $ENV --limit 5
```

### Local Development with Production Data

```bash
#!/bin/bash
PROJECT="abc123"

# 1. Dump production database
echo "Dumping production database..."
upsun db:dump -p $PROJECT -e production --gzip --file prod-db.sql.gz

# 2. Open tunnel to Redis
echo "Opening Redis tunnel..."
upsun tunnel:single redis -p $PROJECT -e production &
TUNNEL_PID=$!
sleep 5

# 3. Run local development
echo "Starting local development..."
export DATABASE_FILE="prod-db.sql.gz"
export REDIS_URL="redis://127.0.0.1:30001"
npm run dev

# 4. Cleanup
kill $TUNNEL_PID
```

### Performance Investigation

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"

echo "=== Performance Investigation ==="

# Check metrics
echo "\n--- CPU Usage (last hour) ---"
upsun cpu -p $PROJECT -e $ENV --start "-1 hour"

echo "\n--- Memory Usage (last hour) ---"
upsun memory -p $PROJECT -e $ENV --start "-1 hour"

# Check slow queries
echo "\n--- Slow Access Logs ---"
upsun logs -p $PROJECT -e $ENV --type access --lines 1000 | \
  grep -E "time:[0-9]{4,}" | \
  head -n 20

# Check error rate
echo "\n--- Recent Errors ---"
upsun logs -p $PROJECT -e $ENV --type error --lines 100 | \
  grep -c "ERROR"
```

## Best Practices

### SSH Usage

- Use SSH for debugging, not regular operations
- Avoid modifying files directly (use deployments)
- Use `--` to separate CLI options from command
- Always test commands on staging first

### Logging

- Use structured logging in applications
- Include request IDs for tracing
- Set appropriate log levels per environment
- Regularly review logs for patterns
- Set up log aggregation for production

### Tunnels

- Close tunnels when done (security)
- Don't commit tunnel credentials
- Use tunnels for debugging, not production access
- Consider tunnel timeouts for long operations

### File Transfer

- Use SCP for ad-hoc transfers only
- Prefer Git for code changes
- Use backups for large data transfers
- Verify file permissions after upload

## Related Commands

**Environments:**
- `environment:info` - Environment information
- See [environments.md](environments.md)

**Databases:**
- `db:dump` - Database exports
- `db:sql` - SQL queries
- See [services-databases.md](services-databases.md)

**Monitoring:**
- `metrics:all` - Performance metrics
- `activity:log` - Activity logs
- See [resources-scaling.md](resources-scaling.md)

## Troubleshooting

**SSH connection fails:**
- Check SSH key added: `ssh-key:list`
- Verify environment is active
- Check for incomplete activities
- Try `ssh-cert:load` for certificate auth

**Tunnel won't open:**
- Check SSH connectivity
- Verify service exists: `service:list`
- Close existing tunnels first
- Check firewall/network restrictions

**Logs not showing:**
- Check application is logging correctly
- Verify log level configuration
- Try different log types
- Check for log rotation

**SCP transfer fails:**
- Verify source path exists
- Check destination permissions
- Ensure sufficient disk space
- Use absolute paths for clarity

For more troubleshooting, see [troubleshooting.md](troubleshooting.md).
