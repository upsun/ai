# Development Tools & Troubleshooting — Reference

## Part 1: Development Tools

Complete guide to SSH, tunnels, logs, and developer tools on Upsun.

### SSH Access

#### Connect via SSH

```bash
upsun environment:ssh -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: ssh

upsun ssh -p abc123 -e production
upsun ssh -p abc123 -e production --app myapp
upsun ssh -p abc123 -e production --worker queue-worker
```

#### Run Single Command

```bash
upsun ssh -p PROJECT_ID -e ENVIRONMENT_NAME -- COMMAND

upsun ssh -p abc123 -e production -- php -v
upsun ssh -p abc123 -e production -- ls -la /app
upsun ssh -p abc123 -e production -- df -h
upsun ssh -p abc123 -e production -- "cd /app && npm run status"
upsun ssh -p abc123 -e production -- "psql -c 'SELECT COUNT(*) FROM users;'"
```

#### Application Status Script

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"

echo "=== Application Status ==="
upsun ssh -p $PROJECT -e $ENV -- "uname -a"
upsun ssh -p $PROJECT -e $ENV -- "php -v"
upsun ssh -p $PROJECT -e $ENV -- "df -h"
upsun ssh -p $PROJECT -e $ENV -- "free -h"
upsun ssh -p $PROJECT -e $ENV -- "ps aux | head -n 10"
```

### File Transfer

#### SCP — Secure Copy

```bash
upsun environment:scp SOURCE DESTINATION
# Alias: scp

upsun scp abc123-production:/app/storage/logs/app.log ./local-app.log   # download
upsun scp ./local-config.json abc123-production:/app/config/             # upload
upsun scp abc123-production:/app/public/uploads/ ./uploads/ -r           # download dir
upsun scp ./build/ abc123-production:/app/public/ -r                     # upload dir
```

Remote format: `PROJECT_ID-ENVIRONMENT:/path`

#### Mount Operations

```bash
upsun mount:upload --mount /app/public/uploads --source ./local-uploads/
upsun mount:download --mount /app/public/uploads --target ./downloaded-uploads/
upsun mount:list -p abc123 -e production
# Alias: mounts
```

### Logs

#### View Application Logs

```bash
upsun environment:logs -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: log

upsun logs -p abc123 -e production
upsun logs -p abc123 -e production --tail
upsun logs -p abc123 -e production --tail --lines 100
```

#### Filter Logs

```bash
upsun logs -p abc123 -e production --app myapp
upsun logs -p abc123 -e production --service database
upsun logs -p abc123 -e production --app api --tail --lines 50
```

#### Log Types

```bash
upsun logs -p abc123 -e production --type app
upsun logs -p abc123 -e production --type access
upsun logs -p abc123 -e production --type error
upsun logs -p abc123 -e production --type deploy
```

#### Log Analysis

```bash
# Find errors in last hour
upsun logs -p abc123 -e production --tail --lines 1000 | grep -i error

# Count 404 errors
upsun logs -p abc123 -e production --type access | grep " 404 " | wc -l

# Find slow requests (>1 second)
upsun logs -p abc123 -e production --type access | grep -E "time:[0-9]{4,}"

# Monitor specific endpoint
upsun logs -p abc123 -e production --tail | grep "/api/users"
```

### Tunnels

```bash
upsun tunnel:open -p PROJECT_ID -e ENV           # all services
upsun tunnel:single RELATIONSHIP -p PROJECT_ID -e ENV  # one service
upsun tunnel:list -p PROJECT_ID -e ENV           # list active (alias: tunnels)
upsun tunnel:info -p PROJECT_ID -e ENV           # connection details
upsun tunnel:close -p PROJECT_ID -e ENV          # close all
```

**With database GUI tools:**
```bash
upsun tunnel:single database -p abc123 -e production
# Host: 127.0.0.1, Port: 30000, User: main, Password: main, DB: main
```

**With local development:**
```bash
upsun tunnel:open -p abc123 -e production
# Update local .env:
# DATABASE_URL=postgresql://main:main@127.0.0.1:30000/main
# REDIS_URL=redis://127.0.0.1:30001
npm run dev
```

### Repository Operations

```bash
upsun repo:read PATH -p PROJECT_ID -e ENV        # view file contents (alias: read)
upsun repo:ls PATH -p PROJECT_ID -e ENV          # list directory
upsun repo:cat FILE -p PROJECT_ID -e ENV         # output file (cat)

upsun read .upsun/config.yaml -p abc123 -e production
upsun repo:cat .upsun/config.yaml -p abc123 -e production > local-config.yaml
```

### Runtime Operations

```bash
upsun operation:list -p PROJECT_ID -e ENV        # list available ops (alias: ops)
upsun operation:run OPERATION -p PROJECT_ID -e ENV

upsun operation:run clear:cache -p abc123 -e production
upsun operation:run reindex -p abc123 -e production --full
```

Common operations: `clear:cache`, `clear:tmp`, `reindex`, `warmup`.

### Xdebug Tunnel

```bash
upsun environment:xdebug -p PROJECT_ID -e ENV
# Alias: xdebug

upsun xdebug -p abc123 -e staging
```

Setup: run `upsun xdebug` → configure IDE to listen on port 9000 → set breakpoints → make HTTP request.

PHPStorm config: Server name: upsun, Port: 9000, IDE key: PHPSTORM.

### Drush (Drupal)

```bash
upsun environment:drush COMMAND -p PROJECT_ID -e ENV
# Alias: drush

upsun drush cr -p abc123 -e production                                # clear cache
upsun drush updatedb -p abc123 -e production                          # run updates
upsun drush config:export -p abc123 -e production                     # export config
upsun drush user:create admin --mail="admin@example.com" -p abc123 -e production
```

### Development Workflows

#### Debug Production Issue

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"

echo "=== Debugging Production Issue ==="
echo "\n--- Recent Error Logs ---"
upsun logs -p $PROJECT -e $ENV --type error --lines 50

echo "\n--- Application Status ---"
upsun ssh -p $PROJECT -e $ENV -- "cd /app && php artisan --version"

echo "\n--- Database Connection ---"
upsun ssh -p $PROJECT -e $ENV -- "psql -c 'SELECT 1;'" >/dev/null 2>&1 \
  && echo "Connected" || echo "Failed"

echo "\n--- Disk Space ---"
upsun ssh -p $PROJECT -e $ENV -- "df -h | grep /app"

echo "\n--- Recent Activities ---"
upsun activity:list -p $PROJECT -e $ENV --limit 5
```

#### Performance Investigation

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"

echo "=== Performance Investigation ==="
echo "\n--- CPU Usage (last hour) ---"
upsun cpu -p $PROJECT -e $ENV --start "-1 hour"

echo "\n--- Memory Usage (last hour) ---"
upsun memory -p $PROJECT -e $ENV --start "-1 hour"

echo "\n--- Slow Access Logs ---"
upsun logs -p $PROJECT -e $ENV --type access --lines 1000 | \
  grep -E "time:[0-9]{4,}" | head -n 20

echo "\n--- Recent Error Count ---"
upsun logs -p $PROJECT -e $ENV --type error --lines 100 | grep -c "ERROR"
```

---

## Part 2: Troubleshooting

Quick reference for diagnosing and resolving common Upsun issues.

### Health Check Script

```bash
#!/bin/bash
PROJECT="${1:-}"
ENV="${2:-production}"

[ -z "$PROJECT" ] && { echo "Usage: $0 PROJECT_ID [ENVIRONMENT]"; exit 1; }

echo "=== Upsun Health Check ==="
echo "Project: $PROJECT | Environment: $ENV | Time: $(date)"

echo "\n--- Authentication ---"
upsun auth:info --no-interaction >/dev/null 2>&1 \
  && echo "Authenticated" || { echo "Not authenticated"; exit 1; }

echo "\n--- Environment Status ---"
upsun environment:info -p $PROJECT -e $ENV status

echo "\n--- Incomplete Activities ---"
upsun activity:list -p $PROJECT -e $ENV -i --limit 5

echo "\n--- Recent Error Logs ---"
upsun logs -p $PROJECT -e $ENV --type error --lines 10 | head -n 15

echo "\n--- Resources ---"
upsun resources -p $PROJECT -e $ENV | head -n 20

echo "\n--- Recent Metrics ---"
upsun cpu -p $PROJECT -e $ENV --start "-1 hour" | tail -n 3
upsun memory -p $PROJECT -e $ENV --start "-1 hour" | tail -n 3
```

### Authentication Issues

**Cannot authenticate:**
```bash
upsun auth:logout
upsun auth:browser-login
# Or use API token:
upsun auth:api-token-login
# Clear cache first if issues persist:
upsun clear-cache && upsun auth:browser-login
```

**SSH key not working:**
```bash
upsun ssh-key:list
ssh-keygen -t ed25519 -C "your@email.com"
upsun ssh-key:add ~/.ssh/id_ed25519.pub
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519
upsun ssh -p PROJECT_ID -e ENV -- echo "Connected"
```

### Deployment Issues

**Build failures:**
```bash
# 1. Check build logs
upsun activity:list -p PROJECT_ID -e ENV --type environment.push --limit 1
upsun activity:log ACTIVITY_ID -p PROJECT_ID

# 2. Clear build cache and redeploy
upsun project:clear-build-cache -p PROJECT_ID
upsun redeploy -p PROJECT_ID -e ENV

# 3. Validate config
upsun validate
```

**Deploy hook fails:**
```bash
# Check deploy logs
upsun activity:log ACTIVITY_ID -p PROJECT_ID | grep -A 20 "deploy hook"

# Test hook manually
upsun ssh -p PROJECT_ID -e ENV -- "cd /app && YOUR_DEPLOY_COMMAND"

# Check service availability
upsun environment:relationships -p PROJECT_ID -e ENV
```

**Deployment stuck:**
```bash
upsun activity:list -p PROJECT_ID -e ENV -i
upsun activity:cancel ACTIVITY_ID -p PROJECT_ID
upsun redeploy -p PROJECT_ID -e ENV
```

### Database Issues

**Cannot connect:**
```bash
upsun service:list -p PROJECT_ID -e ENV
upsun environment:relationships -p PROJECT_ID -e ENV
upsun ssh -p PROJECT_ID -e ENV -- "psql -c 'SELECT 1;'"
upsun logs -p PROJECT_ID -e ENV --service database
```

**Database disk full:**
```bash
upsun disk -p PROJECT_ID -e ENV

# Analyse table sizes (PostgreSQL)
upsun sql -p PROJECT_ID -e ENV -- -c "
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename))
FROM pg_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 10;"

# Increase disk
upsun resources:set -p PROJECT_ID -e ENV
```

**Slow queries:**
```bash
upsun metrics -p PROJECT_ID -e ENV

# Identify slow queries (PostgreSQL)
upsun sql -p PROJECT_ID -e ENV -- -c "
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;"

upsun resources:set -p PROJECT_ID -e ENV --size database:L
```

### Performance Issues

**High CPU:**
```bash
upsun cpu -p PROJECT_ID -e ENV --start "-1 hour"
upsun ssh -p PROJECT_ID -e ENV -- "top -bn1 | head -20"
upsun logs -p PROJECT_ID -e ENV --tail | grep -i error
upsun resources:set -p PROJECT_ID -e ENV --size app:XL
```

**Memory OOM:**
```bash
upsun memory -p PROJECT_ID -e ENV --start "-1 hour"
upsun ssh -p PROJECT_ID -e ENV -- "free -h"
upsun logs -p PROJECT_ID -e ENV | grep -i "memory"
upsun resources:set -p PROJECT_ID -e ENV --size app:XL
```

**Slow page loads:**
```bash
upsun logs -p PROJECT_ID -e ENV --type access | grep -E "time:[0-9]{4,}"
# Optimise: caching, database indexes, CDN for static assets
```

### Network and Access Issues

**Cannot access application:**
```bash
upsun environment:url -p PROJECT_ID -e ENV
upsun routes -p PROJECT_ID -e ENV
upsun domains -p PROJECT_ID
```

**SSL certificate issues:**
```bash
upsun certs -p PROJECT_ID
# Wait for Let's Encrypt: 5–15 minutes
# Add custom cert:
upsun certificate:add cert.crt --key private.key -p PROJECT_ID
```

### Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| "Authentication required" | Not logged in | `upsun auth:browser-login` |
| "Permission denied" | Insufficient permissions | Check role: `user:get` |
| "Environment not found" | Wrong project/env ID | Verify: `environment:list` |
| "Build failed" | Build errors | Check: `activity:log` |
| "Disk quota exceeded" | Out of disk space | `disk` then clean up |
| "Deployment timeout" | Deploy taking too long | Optimise deploy hooks |
| "Out of memory" | Memory limit | Scale: `resources:set` |
| "SSL certificate error" | Certificate issue | Check `certs` and DNS |
| "Cannot connect to database" | Service unavailable | Check `service:list` |
| "Activity cancelled" | Operation interrupted | Retry operation |

### Gather Debug Information for Support

```bash
#!/bin/bash
PROJECT="$1"
ENV="${2:-production}"

cat > debug-info.txt <<EOF
Upsun Debug Information
Generated: $(date)
Project: $PROJECT | Environment: $ENV

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
```
