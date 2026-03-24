# Backup and Restore Operations — Reference

Complete guide to creating, managing, and restoring backups on Upsun.

## Overview

Backups in Upsun capture the complete state of an environment including databases, files, and configuration.

**What's included:**
- All databases (PostgreSQL, MySQL, MongoDB, etc.)
- Persistent file storage (mounts)
- Configuration snapshots
- Environment metadata

**What's NOT included:**
- Application code (use Git)
- Build artifacts (can be rebuilt)
- Temporary files

## Backup Types

### Manual Backups
User-initiated on demand. Retained based on retention policy. Count toward backup quota.

### Automated Backups
System-created on schedule for production environments. No manual intervention needed.

**Retention by plan:**
- Development: 3 days
- Standard: 7 days
- Medium/Large: 14 days

### Live Backups (`--live`)
No downtime. May have slight data inconsistencies if writes occur during backup. Best for production environments with strict uptime requirements.

## Creating Backups

### Standard Backup

```bash
upsun backup:create -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: backup

# With options:
upsun backup -p abc123 -e staging --no-wait
```

What happens: environment briefly paused → data snapshot → environment resumed → backup stored. Typical downtime: 10–30 seconds.

### Live Backup

```bash
upsun backup:create -p PROJECT_ID -e ENVIRONMENT_NAME --live
```

No downtime. Best for production with strict uptime requirements, large datasets, and 24/7 services.

### Pre-Deployment Backup Pattern

```bash
upsun backup:create -p abc123 -e production
sleep 10
upsun backup:list -p abc123 -e production --limit 1
upsun deploy -p abc123 -e production
```

### Automated Backup Script

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"

echo "Creating backup of $ENV environment..."
BACKUP_OUTPUT=$(upsun backup:create -p $PROJECT -e $ENV 2>&1)

if [ $? -eq 0 ]; then
    echo "Backup created successfully"
    BACKUP_ID=$(echo "$BACKUP_OUTPUT" | grep -oP 'backup:\K[a-z0-9]+')
    echo "Backup ID: $BACKUP_ID"
    sleep 30
    upsun backup:get $BACKUP_ID -p $PROJECT -e $ENV
else
    echo "Backup failed"
    exit 1
fi
```

## Viewing and Managing Backups

### List Backups

```bash
upsun backup:list -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: backups

upsun backups -p abc123 -e production
upsun backups -p abc123 -e production --limit 5
```

Example output:
```
+---------------------------+---------------------+--------+
| Backup ID                 | Created             | Size   |
+---------------------------+---------------------+--------+
| 7a9xmk2b5cdfe            | 2025-01-07 10:30:00 | 2.5 GB |
| 6b8ylj1a4bcde            | 2025-01-06 10:30:00 | 2.4 GB |
+---------------------------+---------------------+--------+
```

### View Backup Details

```bash
upsun backup:get BACKUP_ID -p PROJECT_ID -e ENVIRONMENT_NAME
```

Details include: backup ID, creation time, size, type (manual/automated), environment state, databases included, file mounts captured.

### Delete Old Backups

```bash
upsun backup:delete BACKUP_ID -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Safe deletion workflow:**
```bash
upsun backup:list -p abc123 -e production
upsun backup:get OLD_BACKUP_ID -p abc123 -e production
upsun backup:list -p abc123 -e production --limit 3   # ensure newer ones exist
upsun backup:delete OLD_BACKUP_ID -p abc123 -e production
```

### Cleanup Script (Retain N Most Recent)

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"
KEEP_COUNT=7

BACKUPS=$(upsun backup:list -p $PROJECT -e $ENV --pipe)
BACKUP_COUNT=$(echo "$BACKUPS" | wc -l)

if [ $BACKUP_COUNT -le $KEEP_COUNT ]; then
    echo "Only $BACKUP_COUNT backups, nothing to delete"
    exit 0
fi

DELETE_COUNT=$((BACKUP_COUNT - KEEP_COUNT))
echo "Deleting $DELETE_COUNT old backups..."

echo "$BACKUPS" | tail -n $DELETE_COUNT | while read BACKUP_ID; do
    echo "Deleting: $BACKUP_ID"
    upsun backup:delete $BACKUP_ID -p $PROJECT -e $ENV -y
done
```

## Restoring Backups

### Restore to Same Environment

```bash
upsun backup:restore BACKUP_ID -p PROJECT_ID -e ENVIRONMENT_NAME
```

What happens: environment paused → current data safety-backed-up automatically → selected backup data restored → environment restarted. Downtime: 5–15 minutes.

### Restore to Different Environment

```bash
upsun backup:restore BACKUP_ID -p PROJECT_ID -e SOURCE_ENV --target TARGET_ENV

# Clone production to staging:
BACKUP_ID=$(upsun backup:list -p abc123 -e production --limit 1 --pipe | head -1)
upsun backup:restore $BACKUP_ID -p abc123 -e production --target staging
```

### Partial Restores

```bash
upsun backup:restore BACKUP_ID -p abc123 -e production --no-resources    # no resource config change
upsun backup:restore BACKUP_ID -p abc123 -e production --no-code          # data only
upsun backup:restore BACKUP_ID -p abc123 -e production --resources-init backup
```

## Safe Restore Procedure (Full Script)

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"
BACKUP_ID="7a9xmk2b5cdfe"

echo "Starting safe restore procedure..."

echo "1. Verifying backup..."
upsun backup:get $BACKUP_ID -p $PROJECT -e $ENV || { echo "Backup not found"; exit 1; }

echo "2. Creating pre-restore safety backup..."
PRE_RESTORE_OUTPUT=$(upsun backup:create -p $PROJECT -e $ENV --live 2>&1)
PRE_RESTORE_ID=$(echo "$PRE_RESTORE_OUTPUT" | grep -oP 'backup:\K[a-z0-9]+')
echo "Safety backup ID: $PRE_RESTORE_ID"

echo "3. Waiting for safety backup to complete..."
sleep 30
upsun backup:get $PRE_RESTORE_ID -p $PROJECT -e $ENV || { echo "Safety backup failed"; exit 1; }

echo "4. Performing restore..."
upsun backup:restore $BACKUP_ID -p $PROJECT -e $ENV

echo "5. Waiting for restore to complete..."
sleep 60

echo "6. Verifying environment status..."
STATUS=$(upsun environment:info -p $PROJECT -e $ENV status)
echo "Status: $STATUS"

echo "7. Testing environment..."
ENV_URL=$(upsun environment:url -p $PROJECT -e $ENV --primary --pipe)
curl -Is "$ENV_URL" | head -n 1

echo "Restore complete. Safety backup for rollback: $PRE_RESTORE_ID"
```

## Rollback After Failed Restore

```bash
upsun backup:restore PRE_RESTORE_BACKUP_ID -p abc123 -e production
upsun activity:list -p abc123 -e production -i
upsun environment:url -p abc123 -e production --primary
```

## Disaster Recovery

### Recovery Time Objectives (RTO)
- Same environment restore: 5–15 minutes
- Different environment restore: 10–20 minutes
- Full disaster recovery: 15–30 minutes

### Recovery Point Objectives (RPO)
- With automated backups: 24 hours max data loss
- With pre-deployment backups: near zero
- With live backups: minutes to hours

### Disaster Recovery Script

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"

echo "=== DISASTER RECOVERY PROCEDURE ==="
echo "Project: $PROJECT | Environment: $ENV | Started: $(date)"

echo "1. Assessing environment status..."
upsun environment:info -p $PROJECT -e $ENV || echo "Environment not accessible"

echo "2. Available backups:"
upsun backup:list -p $PROJECT -e $ENV

read -p "3. Enter backup ID to restore: " BACKUP_ID
upsun backup:get $BACKUP_ID -p $PROJECT -e $ENV || { echo "Backup verification failed"; exit 1; }

read -p "Confirm restore (yes/no): " CONFIRM
[ "$CONFIRM" != "yes" ] && { echo "Cancelled"; exit 1; }

echo "4. Restoring..."
upsun backup:restore $BACKUP_ID -p $PROJECT -e $ENV

echo "5. Monitoring recovery..."
upsun activity:list -p $PROJECT -e $ENV -i

sleep 60
echo "6. Verifying..."
upsun environment:url -p $PROJECT -e $ENV --primary

echo "=== RECOVERY COMPLETE === (${SECONDS}s)"
```

## Backup Best Practices

### Retention Strategy
- **Daily** - Last 7 days (rapid recovery)
- **Weekly** - Last 4 weeks (recent history)
- **Monthly** - Last 12 months (compliance)
- **Pre-deployment** - Keep until deployment verified successful

### Monthly Restore Testing

```bash
BACKUP_ID=$(upsun backup:list -p abc123 -e production --limit 1 --pipe | head -1)
upsun backup:restore $BACKUP_ID -p abc123 -e production --target staging
upsun environment:url -p abc123 -e staging --primary
echo "Restore test passed: $(date)" >> restore-tests.log
```

## Troubleshooting

**Backup creation fails:**
- Check disk space quota: `upsun disk -p PROJECT -e ENV`
- Verify backup retention limits
- Check for incomplete activities
- Try `--live` backup instead

**Restore takes too long:**
- Expected for large databases
- Monitor with `activity:list -i`
- Check activity logs for progress

**Restore fails:**
- Check activity logs for errors
- Verify backup integrity: `backup:get BACKUP_ID`
- Ensure target environment has capacity
- Check for resource conflicts

**Data inconsistency after live restore:**
- Use standard backup instead (with brief downtime)
- Check application logs for errors
- Verify database integrity via `db:sql`
