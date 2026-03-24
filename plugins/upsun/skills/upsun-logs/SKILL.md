---
name: upsun-logs
description: Use when the user asks to "check logs", "check Upsun status", "view logs", "tail logs", "debug production issue", "SSH to environment", "transfer files", "troubleshoot Upsun", or "monitor deployments". Guides log access, SSH, file transfer, and troubleshooting using the Upsun CLI.
version: 1.0.0
---

# Upsun Logs, SSH & Troubleshooting Skill

Access logs, SSH into environments, transfer files, and troubleshoot Upsun issues.

## Prerequisites

```bash
upsun auth:info
upsun environment:info -p PROJECT_ID -e ENV status   # confirm environment is active
```

## Key Commands

### Logs

```bash
upsun logs -p PROJECT_ID -e ENV                       # View recent logs
upsun logs -p PROJECT_ID -e ENV --tail                # Follow in real-time
upsun logs -p PROJECT_ID -e ENV --tail --lines 100    # Follow with line limit
upsun logs -p PROJECT_ID -e ENV --type error          # Error logs only
upsun logs -p PROJECT_ID -e ENV --type access         # HTTP access logs
upsun logs -p PROJECT_ID -e ENV --type deploy         # Deploy phase logs
upsun logs -p PROJECT_ID -e ENV --app APPNAME         # Filter by application
upsun logs -p PROJECT_ID -e ENV --service database    # Filter by service
```

### SSH & Remote Execution

```bash
upsun ssh -p PROJECT_ID -e ENV                        # Interactive SSH shell
upsun ssh -p PROJECT_ID -e ENV --app APPNAME          # Connect to specific app
upsun ssh -p PROJECT_ID -e ENV --worker WORKER        # Connect to worker
upsun ssh -p PROJECT_ID -e ENV -- COMMAND             # Run single command
upsun ssh -p PROJECT_ID -e ENV -- df -h               # Check disk space
upsun ssh -p PROJECT_ID -e ENV -- free -h             # Check memory
upsun ssh -p PROJECT_ID -e ENV -- "cd /app && php artisan --version"
```

### File Transfer

```bash
upsun scp PROJECT_ID-ENV:/app/path ./local            # Download file
upsun scp ./local PROJECT_ID-ENV:/app/path            # Upload file
upsun mount:upload --mount /app/uploads --source ./local/
upsun mount:download --mount /app/uploads --target ./local/
upsun mount:list -p PROJECT_ID -e ENV                 # List mounts
```

### Activity Monitoring

```bash
upsun activity:list -p PROJECT_ID -e ENV              # Recent activities
upsun activity:list -p PROJECT_ID -e ENV -i           # Incomplete only
upsun activity:log ACTIVITY_ID -p PROJECT_ID          # Stream activity log
upsun activity:cancel ACTIVITY_ID -p PROJECT_ID       # Cancel stuck activity
```

## Quick Debug Workflow

```bash
# 1. Check recent errors
upsun logs -p PROJECT_ID -e production --type error --lines 50

# 2. Check environment health
upsun environment:info -p PROJECT_ID -e production status
upsun activity:list -p PROJECT_ID -e production -i

# 3. SSH for deeper inspection
upsun ssh -p PROJECT_ID -e production -- "df -h && free -h && ps aux | head -15"

# 4. Check database connectivity
upsun ssh -p PROJECT_ID -e production -- "psql -c 'SELECT 1;'"

# 5. Check recent error count
upsun logs -p PROJECT_ID -e production --type error --lines 100 | grep -c ERROR
```

## Common Error Reference

| Error message | Diagnose with | Typical fix |
|---|---|---|
| Build failed | `activity:log ACTIVITY_ID` | Fix build hook; clear cache: `project:clear-build-cache` |
| Deploy hook fails | `activity:log ACTIVITY_ID \| grep -A20 "deploy hook"` | Check DB migrations, service availability |
| Deployment stuck | `activity:list -i` | Cancel: `activity:cancel`, then `redeploy` |
| Out of memory | `upsun memory --start "-1 hour"` | Scale up: `resources:set --size app:XL` |
| Cannot connect to DB | `service:list`, `environment:relationships` | Check service status, try tunnel |
| Domain not resolving | `domain:list`, `route:list` | Verify DNS, wait propagation (up to 48h) |
| SSH key rejected | `ssh-key:list` | `ssh-key:add ~/.ssh/id_ed25519.pub` |
| Disk quota exceeded | `upsun disk` | Clean up data, increase allocation via `resources:set` |

## Log Analysis Examples

```bash
# Find errors in last hour
upsun logs -p PROJECT_ID -e production --tail --lines 1000 | grep -i error

# Count HTTP 404s
upsun logs -p PROJECT_ID -e production --type access | grep " 404 " | wc -l

# Find slow requests (>1 second)
upsun logs -p PROJECT_ID -e production --type access | grep -E "time:[0-9]{4,}"

# Monitor a specific endpoint
upsun logs -p PROJECT_ID -e production --tail | grep "/api/users"
```

## Reference

See [reference.md](reference.md) for:
- Full SSH workflow scripts (application status, cache clearing)
- Drush (Drupal) command patterns
- Xdebug tunnel setup
- Repository file inspection (`repo:read`, `repo:ls`, `repo:cat`)
- Runtime operations (`operation:list`, `operation:run`)
- Complete troubleshooting guide for all error categories
- Health check and monitoring scripts
