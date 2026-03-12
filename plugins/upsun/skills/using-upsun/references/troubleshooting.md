# Troubleshooting Common Issues

Quick reference for diagnosing and resolving common Upsun issues.

## Overview

This guide covers common problems and their solutions. For specific areas, see:
- [Environments](environments.md) - Environment-specific issues
- [Deployments](deployments.md) - Deployment problems
- [Backups](backups.md) - Backup/restore issues
- [Services/Databases](services-databases.md) - Database problems
- [Resources](resources-scaling.md) - Performance issues
- [Access/Security](access-security.md) - Authentication problems

## Quick Diagnostics

### Health Check Script

Run this to diagnose environment issues:

```bash
#!/bin/bash
PROJECT="${1:-}"
ENV="${2:-production}"

if [ -z "$PROJECT" ]; then
    echo "Usage: $0 PROJECT_ID [ENVIRONMENT]"
    exit 1
fi

echo "=== Upsun Health Check ==="
echo "Project: $PROJECT"
echo "Environment: $ENV"
echo "Time: $(date)"

# Authentication
echo -e "\n--- Authentication ---"
if upsun auth:info --no-interaction >/dev/null 2>&1; then
    echo "✅ Authenticated"
else
    echo "❌ Not authenticated - run: upsun auth:browser-login"
    exit 1
fi

# Environment status
echo -e "\n--- Environment Status ---"
STATUS=$(upsun environment:info -p $PROJECT -e $ENV status 2>&1)
if [ $? -eq 0 ]; then
    echo "Status: $STATUS"
else
    echo "❌ Cannot access environment"
    echo "$STATUS"
    exit 1
fi

# Incomplete activities
echo -e "\n--- Incomplete Activities ---"
INCOMPLETE=$(upsun activity:list -p $PROJECT -e $ENV -i --pipe 2>&1 | wc -l)
if [ $INCOMPLETE -gt 0 ]; then
    echo "⚠️  $INCOMPLETE incomplete activities"
    upsun activity:list -p $PROJECT -e $ENV -i --limit 5
else
    echo "✅ No incomplete activities"
fi

# Recent errors
echo -e "\n--- Recent Error Logs ---"
upsun logs -p $PROJECT -e $ENV --type error --lines 10 2>&1 | head -n 15

# Resources
echo -e "\n--- Resources ---"
upsun resources -p $PROJECT -e $ENV 2>&1 | head -n 20

# Metrics
echo -e "\n--- Recent Metrics ---"
echo "CPU (last hour):"
upsun cpu -p $PROJECT -e $ENV --start "-1 hour" 2>&1 | tail -n 3
echo "Memory (last hour):"
upsun memory -p $PROJECT -e $ENV --start "-1 hour" 2>&1 | tail -n 3

echo -e "\n=== Health Check Complete ==="
```

## Authentication Issues

### Cannot Authenticate

**Symptoms:**
- `upsun auth:info` fails
- Commands return authentication errors
- "Not logged in" messages

**Solutions:**

1. **Re-login:**
   ```bash
   upsun auth:logout
   upsun auth:browser-login
   ```

2. **Clear cache:**
   ```bash
   upsun clear-cache
   upsun auth:browser-login
   ```

3. **Use API token:**
   ```bash
   upsun auth:api-token-login
   # Enter API token from Console
   ```

4. **Check credentials location:**
   ```bash
   ls -la ~/.platformsh/
   # Should contain credentials.json
   ```

### SSH Key Not Working

**Symptoms:**
- SSH connection refused
- "Permission denied (publickey)"
- Git push fails

**Solutions:**

1. **List SSH keys:**
   ```bash
   upsun ssh-key:list
   ```

2. **Add SSH key:**
   ```bash
   ssh-keygen -t ed25519 -C "your@email.com"
   upsun ssh-key:add ~/.ssh/id_ed25519.pub
   ```

3. **Check SSH agent:**
   ```bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ssh-add -l
   ```

4. **Test SSH connection:**
   ```bash
   upsun ssh -p PROJECT_ID -e ENVIRONMENT_NAME -- echo "Connected"
   ```

## Deployment Issues

### Build Failures

**Symptoms:**
- Deployment fails during build phase
- "Build failed" in activity logs
- Dependencies not installing

**Solutions:**

1. **Check build logs:**
   ```bash
   upsun activity:list -p PROJECT_ID -e ENV --type environment.push --limit 1
   # Get activity ID
   upsun activity:log ACTIVITY_ID -p PROJECT_ID
   ```

2. **Clear build cache:**
   ```bash
   upsun project:clear-build-cache -p PROJECT_ID
   upsun redeploy -p PROJECT_ID -e ENVIRONMENT_NAME
   ```

3. **Check disk space during build:**
   ```bash
   # Increase build resources temporarily
   upsun resources:build:set -p PROJECT_ID
   ```

4. **Validate configuration:**
   ```bash
   upsun validate
   ```

### Deploy Hook Fails

**Symptoms:**
- Build succeeds but deploy fails
- Database migration errors
- Permission issues

**Solutions:**

1. **Check deploy logs:**
   ```bash
   upsun activity:log ACTIVITY_ID -p PROJECT_ID | grep -A 20 "deploy hook"
   ```

2. **Test hook locally:**
   ```bash
   upsun ssh -p PROJECT_ID -e ENVIRONMENT_NAME -- "cd /app && YOUR_DEPLOY_COMMAND"
   ```

3. **Check for service availability:**
   ```bash
   upsun environment:relationships -p PROJECT_ID -e ENVIRONMENT_NAME
   ```

4. **Increase timeout (in .upsun/config.yaml):**
   ```yaml
   hooks:
     deploy: |
       set -e
       # Your commands with more time allowed
   ```

### Deployment Stuck

**Symptoms:**
- Activity shows "in progress" for long time
- No log output
- Environment unresponsive

**Solutions:**

1. **Check activity status:**
   ```bash
   upsun activity:list -p PROJECT_ID -e ENVIRONMENT_NAME -i
   ```

2. **Cancel stuck activity:**
   ```bash
   upsun activity:cancel ACTIVITY_ID -p PROJECT_ID
   ```

3. **Redeploy:**
   ```bash
   upsun redeploy -p PROJECT_ID -e ENVIRONMENT_NAME
   ```

4. **Check for resource limits:**
   ```bash
   upsun resources -p PROJECT_ID -e ENVIRONMENT_NAME
   ```

## Database Issues

### Cannot Connect to Database

**Symptoms:**
- Application shows database errors
- Connection timeouts
- "Could not connect to database"

**Solutions:**

1. **Check service status:**
   ```bash
   upsun service:list -p PROJECT_ID -e ENVIRONMENT_NAME
   ```

2. **Verify relationships:**
   ```bash
   upsun environment:relationships -p PROJECT_ID -e ENVIRONMENT_NAME
   ```

3. **Test connection via SSH:**
   ```bash
   upsun ssh -p PROJECT_ID -e ENVIRONMENT_NAME -- "psql -c 'SELECT 1;'"
   ```

4. **Check database logs:**
   ```bash
   upsun logs -p PROJECT_ID -e ENVIRONMENT_NAME --service database
   ```

### Database Disk Full

**Symptoms:**
- Cannot write to database
- Disk quota exceeded errors
- Backup creation fails

**Solutions:**

1. **Check disk usage:**
   ```bash
   upsun disk -p PROJECT_ID -e ENVIRONMENT_NAME
   ```

2. **Analyze table sizes:**
   ```bash
   upsun sql -p PROJECT_ID -e ENVIRONMENT_NAME -- -c "
   SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename))
   FROM pg_tables
   ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
   LIMIT 10;"
   ```

3. **Clean up data:**
   ```bash
   # Delete old records, logs, etc.
   upsun ssh -p PROJECT_ID -e ENVIRONMENT_NAME -- "cd /app && php artisan cleanup"
   ```

4. **Increase disk allocation:**
   ```bash
   upsun resources:set -p PROJECT_ID -e ENVIRONMENT_NAME
   # Select larger disk size
   ```

### Slow Queries

**Symptoms:**
- Application slowness
- Timeouts
- High database CPU usage

**Solutions:**

1. **Check database metrics:**
   ```bash
   upsun metrics -p PROJECT_ID -e ENVIRONMENT_NAME
   ```

2. **Identify slow queries:**
   ```bash
   upsun sql -p PROJECT_ID -e ENVIRONMENT_NAME -- -c "
   SELECT query, calls, total_time, mean_time
   FROM pg_stat_statements
   ORDER BY mean_time DESC
   LIMIT 10;"
   ```

3. **Add indexes:**
   ```bash
   upsun sql -p PROJECT_ID -e ENVIRONMENT_NAME -- -c "
   CREATE INDEX CONCURRENTLY idx_users_email ON users(email);"
   ```

4. **Scale database resources:**
   ```bash
   upsun resources:set -p PROJECT_ID -e ENVIRONMENT_NAME --size database:L
   ```

## Performance Issues

### High CPU Usage

**Symptoms:**
- Application slowness
- Timeout errors
- CPU metrics > 90%

**Solutions:**

1. **Check CPU metrics:**
   ```bash
   upsun cpu -p PROJECT_ID -e ENVIRONMENT_NAME --start "-1 hour"
   ```

2. **Identify CPU-intensive processes:**
   ```bash
   upsun ssh -p PROJECT_ID -e ENVIRONMENT_NAME -- "top -bn1 | head -20"
   ```

3. **Check for infinite loops:**
   ```bash
   upsun logs -p PROJECT_ID -e ENVIRONMENT_NAME --tail | grep -i error
   ```

4. **Scale up resources:**
   ```bash
   upsun resources:set -p PROJECT_ID -e ENVIRONMENT_NAME --size app:XL
   ```

### Memory Issues (OOM)

**Symptoms:**
- Application crashes
- 502/503 errors
- "Out of memory" in logs

**Solutions:**

1. **Check memory usage:**
   ```bash
   upsun memory -p PROJECT_ID -e ENVIRONMENT_NAME --start "-1 hour"
   ```

2. **Analyze memory consumption:**
   ```bash
   upsun ssh -p PROJECT_ID -e ENVIRONMENT_NAME -- "free -h"
   ```

3. **Check for memory leaks:**
   ```bash
   upsun logs -p PROJECT_ID -e ENVIRONMENT_NAME | grep -i "memory"
   ```

4. **Increase memory:**
   ```bash
   upsun resources:set -p PROJECT_ID -e ENVIRONMENT_NAME --size app:XL
   ```

5. **Optimize application:**
   - Reduce memory-intensive operations
   - Implement pagination
   - Use Redis for caching
   - Optimize image processing

### Slow Page Loads

**Symptoms:**
- High response times
- User complaints
- Slow access logs

**Solutions:**

1. **Check access logs:**
   ```bash
   upsun logs -p PROJECT_ID -e ENVIRONMENT_NAME --type access | grep -E "time:[0-9]{4,}"
   ```

2. **Enable caching:**
   - Configure HTTP caching in routes
   - Implement application-level caching
   - Use Redis/Valkey for sessions

3. **Optimize database:**
   - Add indexes
   - Optimize queries
   - Enable query caching

4. **Use CDN:**
   - Serve static assets from CDN
   - Enable asset compression
   - Optimize images

## Environment Issues

### Environment Won't Start

**Symptoms:**
- Environment stuck in "building" state
- Cannot access application
- Deployment hangs

**Solutions:**

1. **Check for incomplete activities:**
   ```bash
   upsun activity:list -p PROJECT_ID -e ENVIRONMENT_NAME -i
   ```

2. **Cancel and redeploy:**
   ```bash
   upsun activity:cancel ACTIVITY_ID -p PROJECT_ID
   upsun redeploy -p PROJECT_ID -e ENVIRONMENT_NAME
   ```

3. **Check resource limits:**
   ```bash
   upsun subscription:info -p PROJECT_ID
   ```

4. **Review environment info:**
   ```bash
   upsun environment:info -p PROJECT_ID -e ENVIRONMENT_NAME
   ```

### Cannot Delete Environment

**Symptoms:**
- Delete command fails
- "Environment in use" error
- Permission denied

**Solutions:**

1. **Check for active deployments:**
   ```bash
   upsun activity:list -p PROJECT_ID -e ENVIRONMENT_NAME -i
   ```

2. **Deactivate first:**
   ```bash
   upsun environment:pause -p PROJECT_ID -e ENVIRONMENT_NAME
   ```

3. **Check for child environments:**
   ```bash
   upsun environment:list -p PROJECT_ID
   ```

4. **Force delete (caution):**
   ```bash
   upsun environment:delete -p PROJECT_ID -e ENVIRONMENT_NAME --delete-branch
   ```

## Network and Access Issues

### Cannot Access Application

**Symptoms:**
- 404 errors
- Domain not resolving
- SSL errors

**Solutions:**

1. **Check environment URL:**
   ```bash
   upsun environment:url -p PROJECT_ID -e ENVIRONMENT_NAME
   ```

2. **Verify DNS:**
   ```bash
   dig your-domain.com
   nslookup your-domain.com
   ```

3. **Check routes:**
   ```bash
   upsun routes -p PROJECT_ID -e ENVIRONMENT_NAME
   ```

4. **Check domain configuration:**
   ```bash
   upsun domains -p PROJECT_ID
   ```

### SSL Certificate Issues

**Symptoms:**
- "Not secure" warning
- Certificate expired
- Certificate mismatch

**Solutions:**

1. **Check certificates:**
   ```bash
   upsun certs -p PROJECT_ID
   ```

2. **Verify domain points to Upsun:**
   ```bash
   dig your-domain.com
   # Should point to Upsun infrastructure
   ```

3. **Wait for Let's Encrypt:**
   - Auto-provision takes 5-15 minutes
   - Check domain is verified
   - Ensure DNS is correct

4. **Add custom certificate:**
   ```bash
   upsun certificate:add cert.crt --key private.key -p PROJECT_ID
   ```

## Backup and Restore Issues

### Backup Fails

**Symptoms:**
- Backup creation times out
- "Backup failed" error
- Incomplete backup

**Solutions:**

1. **Try live backup:**
   ```bash
   upsun backup:create -p PROJECT_ID -e ENVIRONMENT_NAME --live
   ```

2. **Check disk quota:**
   ```bash
   upsun disk -p PROJECT_ID -e ENVIRONMENT_NAME
   ```

3. **Check for incomplete activities:**
   ```bash
   upsun activity:list -p PROJECT_ID -e ENVIRONMENT_NAME -i
   ```

4. **Retry after cleanup:**
   ```bash
   # Clean up old backups
   upsun backup:list -p PROJECT_ID -e ENVIRONMENT_NAME
   # Delete old ones
   upsun backup:delete OLD_BACKUP_ID -p PROJECT_ID -e ENVIRONMENT_NAME
   # Retry
   upsun backup:create -p PROJECT_ID -e ENVIRONMENT_NAME
   ```

### Restore Fails

**Symptoms:**
- Restore hangs
- Data not restored
- Environment broken after restore

**Solutions:**

1. **Check backup validity:**
   ```bash
   upsun backup:get BACKUP_ID -p PROJECT_ID -e ENVIRONMENT_NAME
   ```

2. **Verify target environment:**
   ```bash
   upsun environment:info -p PROJECT_ID -e ENVIRONMENT_NAME status
   ```

3. **Restore to test environment first:**
   ```bash
   upsun backup:restore BACKUP_ID -p PROJECT_ID -e production --target staging
   ```

4. **Check activity logs:**
   ```bash
   upsun activity:list -p PROJECT_ID -e ENVIRONMENT_NAME -i
   upsun activity:log ACTIVITY_ID -p PROJECT_ID
   ```

## Getting Help

### Gather Debug Information

Before contacting support, gather:

```bash
#!/bin/bash
PROJECT="$1"
ENV="${2:-production}"

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
```

### Contact Support

- **Documentation**: https://docs.upsun.com
- **Support Portal**: Upsun Console → Support
- **Status Page**: https://status.upsun.com
- **Community**: Upsun Community Forums

### Useful Commands for Support

```bash
# System information
upsun --version
upsun auth:info

# Project state
upsun project:info -p PROJECT_ID
upsun environment:info -p PROJECT_ID -e ENVIRONMENT_NAME

# Recent activities
upsun activity:list -p PROJECT_ID -e ENVIRONMENT_NAME --limit 20

# Failed activity logs
upsun activity:log FAILED_ACTIVITY_ID -p PROJECT_ID

# Configuration validation
upsun validate
```

## Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| "Authentication required" | Not logged in | Run `upsun auth:browser-login` |
| "Permission denied" | Insufficient permissions | Check user role with `user:get` |
| "Environment not found" | Wrong project/env ID | Verify with `environment:list` |
| "Build failed" | Build errors | Check logs with `activity:log` |
| "Disk quota exceeded" | Out of disk space | Check `disk` and clean up |
| "Deployment timeout" | Deploy taking too long | Optimize deploy hooks |
| "Out of memory" | Memory limit reached | Scale up with `resources:set` |
| "SSL certificate error" | Certificate issue | Check `certs` and DNS |
| "Cannot connect to database" | Service unavailable | Check `service:list` |
| "Activity cancelled" | Operation interrupted | Retry operation |

## Prevention

### Best Practices

1. **Regular backups** - Before major changes
2. **Test on staging** - Never deploy directly to production
3. **Monitor metrics** - Set up alerts
4. **Validate configuration** - Before commits
5. **Review logs** - Regularly check for errors
6. **Update dependencies** - Keep software current
7. **Document changes** - Maintain change log
8. **Capacity planning** - Monitor resource trends

### Monitoring Script

```bash
#!/bin/bash
# Run daily to catch issues early

PROJECT="abc123"
ENV="production"

# CPU check
CPU=$(upsun cpu -p $PROJECT -e $ENV --start "-1 hour" 2>&1 | grep -oP '\d+(?=%)' | tail -n 1)
if [ "$CPU" -gt 80 ]; then
    echo "⚠️  High CPU: ${CPU}%"
fi

# Memory check
MEM=$(upsun memory -p $PROJECT -e $ENV --start "-1 hour" 2>&1 | grep -oP '\d+(?=%)' | tail -n 1)
if [ "$MEM" -gt 85 ]; then
    echo "⚠️  High Memory: ${MEM}%"
fi

# Disk check
DISK=$(upsun disk -p $PROJECT -e $ENV 2>&1 | grep -oP '\d+(?=%)' | tail -n 1)
if [ "$DISK" -gt 80 ]; then
    echo "⚠️  High Disk Usage: ${DISK}%"
fi

# Error check
ERROR_COUNT=$(upsun logs -p $PROJECT -e $ENV --type error --lines 100 2>&1 | grep -c "ERROR")
if [ "$ERROR_COUNT" -gt 10 ]; then
    echo "⚠️  High error count: $ERROR_COUNT errors in last 100 log lines"
fi
```
