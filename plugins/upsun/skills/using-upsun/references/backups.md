# Backup and Restore Operations

Complete guide to creating, managing, and restoring backups on Upsun for data protection and disaster recovery.

## Overview

Backups in Upsun capture the complete state of an environment including databases, files, and configuration. Understanding backup types, retention policies, and restore procedures is essential for data safety.

**What's Included in Backups:**
- All databases (PostgreSQL, MySQL, MongoDB, etc.)
- Persistent file storage (mounts)
- Configuration snapshots
- Environment metadata

**What's NOT Included:**
- Application code (use Git for version control)
- Build artifacts (can be rebuilt)
- Temporary files

## Backup Types

### Manual Backups

User-initiated backups created on demand:

**Characteristics:**
- Created when you need them
- Retained based on retention policy
- Counted toward backup quota
- Can be created while environment is active

### Automated Backups

System-created backups on a schedule:

**Characteristics:**
- Created automatically for production environments
- Daily backups retained based on plan
- No manual intervention required
- Occur during low-activity periods

**Retention by plan:**
- **Development** - 3 days
- **Standard** - 7 days
- **Medium** - 14 days
- **Large/X-Large** - 14 days

### Live Backups

Backups created without stopping the environment:

**Characteristics:**
- No downtime during backup
- May have slight data inconsistencies
- Faster than standard backups
- Uses `--live` flag

**Use for:**
- Production environments where downtime unacceptable
- Large databases
- High-traffic applications

## Creating Backups

### Create Standard Backup

Create a backup with brief environment pause:

```bash
upsun backup:create -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Examples:**

**Backup production environment:**
```bash
upsun backup:create -p abc123 -e production
```

**With custom options:**
```bash
upsun backup -p abc123 -e staging --no-wait
```

**What happens:**
1. Environment briefly paused
2. Data snapshot created
3. Environment resumed
4. Backup stored and indexed

**Typical downtime:** 10-30 seconds depending on data size

### Create Live Backup

Create backup without downtime:

```bash
upsun backup:create -p PROJECT_ID -e ENVIRONMENT_NAME --live
```

**Example:**
```bash
upsun backup:create -p abc123 -e production --live
```

**Considerations:**
- No downtime
- Possible data inconsistencies if writes occur during backup
- Best for read-heavy applications
- Longer backup time

**When to use live backups:**
- Production with strict uptime requirements
- 24/7 services
- High-traffic periods
- Large datasets

### Pre-Deployment Backup

Always backup before major changes:

```bash
# Create backup before deployment
upsun backup:create -p abc123 -e production

# Wait for backup to complete
sleep 10

# Verify backup created
upsun backup:list -p abc123 -e production --limit 1

# Proceed with deployment
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
    echo "✅ Backup created successfully"

    # Extract backup ID from output
    BACKUP_ID=$(echo "$BACKUP_OUTPUT" | grep -oP 'backup:\K[a-z0-9]+')
    echo "Backup ID: $BACKUP_ID"

    # Wait for backup to complete
    sleep 30

    # Verify backup
    upsun backup:get $BACKUP_ID -p $PROJECT -e $ENV
else
    echo "❌ Backup failed"
    exit 1
fi
```

## Viewing and Managing Backups

### List Available Backups

View all backups for an environment:

```bash
upsun backup:list -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Examples:**

**List all backups:**
```bash
upsun backups -p abc123 -e production
```

**Limit results:**
```bash
upsun backups -p abc123 -e production --limit 5
```

**Output format:**
```
+---------------------------+---------------------+------------+
| Backup ID                 | Created             | Size       |
+---------------------------+---------------------+------------+
| 7a9xmk2b5cdfe            | 2025-01-07 10:30:00 | 2.5 GB     |
| 6b8ylj1a4bcde            | 2025-01-06 10:30:00 | 2.4 GB     |
| 5c7xki0z3abcd            | 2025-01-05 10:30:00 | 2.4 GB     |
+---------------------------+---------------------+------------+
```

### View Backup Details

Get detailed information about a specific backup:

```bash
upsun backup:get BACKUP_ID -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example:**
```bash
upsun backup:get 7a9xmk2b5cdfe -p abc123 -e production
```

**Details include:**
- Backup ID and creation time
- Backup size and type (manual/automated)
- Environment state snapshot
- Included databases
- File mounts captured
- Restore capability

### Delete Old Backups

Remove backups to free quota:

```bash
upsun backup:delete BACKUP_ID -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example:**
```bash
upsun backup:delete 5c7xki0z3abcd -p abc123 -e production
```

**⚠️ Warning**: Deletion is permanent and cannot be undone.

**Safe deletion workflow:**

```bash
# 1. List backups
upsun backup:list -p abc123 -e production

# 2. Verify backup age and size
upsun backup:get OLD_BACKUP_ID -p abc123 -e production

# 3. Ensure newer backups exist
upsun backup:list -p abc123 -e production --limit 3

# 4. Delete old backup
upsun backup:delete OLD_BACKUP_ID -p abc123 -e production
```

### Cleanup Script

Automate old backup deletion:

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"
KEEP_COUNT=7

echo "Cleaning up old backups, keeping $KEEP_COUNT most recent..."

# Get all backup IDs
BACKUPS=$(upsun backup:list -p $PROJECT -e $ENV --pipe)
BACKUP_COUNT=$(echo "$BACKUPS" | wc -l)

if [ $BACKUP_COUNT -le $KEEP_COUNT ]; then
    echo "Only $BACKUP_COUNT backups exist, nothing to delete"
    exit 0
fi

# Delete old backups
DELETE_COUNT=$((BACKUP_COUNT - KEEP_COUNT))
echo "Deleting $DELETE_COUNT old backups..."

echo "$BACKUPS" | tail -n $DELETE_COUNT | while read BACKUP_ID; do
    echo "Deleting backup: $BACKUP_ID"
    upsun backup:delete $BACKUP_ID -p $PROJECT -e $ENV -y
done

echo "✅ Cleanup complete"
```

## Restoring Backups

### Restore to Same Environment

Restore a backup to the original environment:

```bash
upsun backup:restore BACKUP_ID -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example:**
```bash
upsun backup:restore 7a9xmk2b5cdfe -p abc123 -e production
```

**⚠️ Warning**: This will overwrite current environment data.

**What happens:**
1. Environment paused
2. Current data backed up automatically (safety backup)
3. Selected backup data restored
4. Environment restarted
5. Application redeployed

**Downtime:** 5-15 minutes depending on data size

### Restore to Different Environment

Restore backup to a different environment (e.g., staging):

```bash
upsun backup:restore BACKUP_ID -p PROJECT_ID -e SOURCE_ENV --target TARGET_ENV
```

**Example - Clone production to staging:**
```bash
# Get latest production backup
upsun backup:list -p abc123 -e production --limit 1

# Restore to staging
upsun backup:restore 7a9xmk2b5cdfe -p abc123 -e production --target staging
```

**Use cases:**
- Refresh staging with production data
- Create test environment with real data
- Investigate production issues in safe environment
- Validate backup integrity

### Partial Restores

Restore only specific components:

**Restore code only (no data):**
```bash
upsun backup:restore BACKUP_ID -p abc123 -e production --no-resources
```

**Restore data only (no code):**
```bash
upsun backup:restore BACKUP_ID -p abc123 -e production --no-code
```

**Custom resource initialization:**
```bash
upsun backup:restore BACKUP_ID -p abc123 -e production --resources-init backup
```

**Options:**
- `--no-code` - Don't restore code snapshot
- `--no-resources` - Don't restore resource configuration
- `--resources-init [backup|parent|minimal]` - How to initialize resources

## Safe Restore Workflow

### Complete Safe Restore Procedure

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"
BACKUP_ID="7a9xmk2b5cdfe"

echo "Starting safe restore procedure..."

# Step 1: Verify backup exists and is valid
echo "1. Verifying backup..."
upsun backup:get $BACKUP_ID -p $PROJECT -e $ENV || {
    echo "❌ Backup not found or invalid"
    exit 1
}

# Step 2: Create pre-restore backup
echo "2. Creating pre-restore safety backup..."
PRE_RESTORE_OUTPUT=$(upsun backup:create -p $PROJECT -e $ENV --live 2>&1)
PRE_RESTORE_ID=$(echo "$PRE_RESTORE_OUTPUT" | grep -oP 'backup:\K[a-z0-9]+')
echo "Pre-restore backup ID: $PRE_RESTORE_ID"

# Step 3: Wait for pre-restore backup to complete
echo "3. Waiting for pre-restore backup to complete..."
sleep 30

# Step 4: Verify pre-restore backup
upsun backup:get $PRE_RESTORE_ID -p $PROJECT -e $ENV || {
    echo "❌ Pre-restore backup failed"
    exit 1
}

# Step 5: Notify team
echo "4. Notifying team about restore..."
echo "Restoring backup $BACKUP_ID to $ENV"
echo "Safety backup created: $PRE_RESTORE_ID"

# Step 6: Perform restore
echo "5. Performing restore..."
upsun backup:restore $BACKUP_ID -p $PROJECT -e $ENV

# Step 7: Wait for restore to complete
echo "6. Waiting for restore to complete..."
sleep 60

# Step 8: Verify environment is active
echo "7. Verifying environment status..."
STATUS=$(upsun environment:info -p $PROJECT -e $ENV status)
if [[ "$STATUS" == *"active"* ]]; then
    echo "✅ Environment is active"
else
    echo "⚠️ Environment status: $STATUS"
fi

# Step 9: Test critical functionality
echo "8. Testing environment..."
ENV_URL=$(upsun environment:url -p $PROJECT -e $ENV --primary --pipe)
echo "Environment URL: $ENV_URL"
curl -Is "$ENV_URL" | head -n 1

# Step 10: Document restore
echo "9. Documenting restore..."
echo "Restore completed at $(date)"
echo "Backup restored: $BACKUP_ID"
echo "Safety backup: $PRE_RESTORE_ID (keep for rollback)"

echo "✅ Restore procedure complete"
```

### Testing Restored Environment

After restore, verify:

1. **Environment accessibility:**
   ```bash
   upsun environment:url -p abc123 -e production --primary --browser
   ```

2. **Database integrity:**
   ```bash
   upsun ssh -p abc123 -e production -- "psql -c 'SELECT COUNT(*) FROM users;'"
   ```

3. **File mounts:**
   ```bash
   upsun ssh -p abc123 -e production -- "ls -lah /app/public/uploads"
   ```

4. **Application logs:**
   ```bash
   upsun logs -p abc123 -e production --tail
   ```

5. **Functionality tests:**
   - Login/authentication
   - Critical user flows
   - API endpoints
   - External integrations

### Rollback After Failed Restore

If restore causes issues, rollback to pre-restore backup:

```bash
# Restore the pre-restore safety backup
upsun backup:restore PRE_RESTORE_BACKUP_ID -p abc123 -e production

# Monitor restore
upsun activity:list -p abc123 -e production -i

# Verify rollback succeeded
upsun environment:url -p abc123 -e production --primary --browser
```

## Backup Best Practices

### Before Major Changes

Always backup before:
- Production deployments
- Database migrations
- Configuration changes
- Resource modifications
- Code refactoring
- Third-party integrations

**Pre-change checklist:**
```bash
# 1. Create backup
upsun backup:create -p abc123 -e production --live

# 2. Verify backup
upsun backup:list -p abc123 -e production --limit 1

# 3. Document backup ID
echo "Backup created: [BACKUP_ID] at $(date)"

# 4. Proceed with change
```

### Regular Testing

Test restore procedures regularly:

```bash
# Monthly restore test to staging
# 1. Get latest production backup
BACKUP_ID=$(upsun backup:list -p abc123 -e production --limit 1 --pipe | head -n 1)

# 2. Restore to staging
upsun backup:restore $BACKUP_ID -p abc123 -e production --target staging

# 3. Test staging
upsun environment:url -p abc123 -e staging --primary --browser

# 4. Document test
echo "Restore test passed: $(date)" >> restore-tests.log
```

### Retention Strategy

**Keep backups for:**
- **Daily** - Last 7 days (rapid recovery)
- **Weekly** - Last 4 weeks (recent history)
- **Monthly** - Last 12 months (compliance)
- **Pre-deployment** - Until verified successful

**Example retention schedule:**
```
- Today's automated backup
- Yesterday's automated backup
- Last 7 days of dailies
- Every Sunday for 4 weeks
- 1st of month for 12 months
- Pre-deployment backups for 30 days
```

### Documentation

Document each backup:

```bash
# Create backup with meaningful note
upsun backup:create -p abc123 -e production

# Document in backup log
cat >> backup-log.md <<EOF
## $(date +%Y-%m-%d)
- **Backup ID**: [BACKUP_ID]
- **Reason**: Pre-deployment backup before v2.5.0
- **Environment**: production
- **Created by**: $(whoami)
- **Size**: [SIZE]
EOF
```

## Disaster Recovery

### Recovery Time Objectives (RTO)

Expected time to restore service:

- **Same environment restore**: 5-15 minutes
- **Different environment restore**: 10-20 minutes
- **Full disaster recovery**: 15-30 minutes

### Recovery Point Objectives (RPO)

Maximum acceptable data loss:

- **With automated backups**: 24 hours max
- **With pre-deployment backups**: Near zero
- **With live backups**: Minutes to hours

### Disaster Recovery Plan

```bash
#!/bin/bash
# disaster-recovery.sh - Complete disaster recovery procedure

PROJECT="abc123"
ENV="production"

echo "=== DISASTER RECOVERY PROCEDURE ==="
echo "Project: $PROJECT"
echo "Environment: $ENV"
echo "Started: $(date)"

# Step 1: Assess damage
echo "\n1. Assessing environment status..."
upsun environment:info -p $PROJECT -e $ENV || {
    echo "❌ Environment not accessible"
}

# Step 2: List available backups
echo "\n2. Listing available backups..."
upsun backup:list -p $PROJECT -e $ENV

# Step 3: Select latest good backup
echo "\n3. Select backup to restore:"
read -p "Enter backup ID: " BACKUP_ID

# Step 4: Verify backup
echo "\n4. Verifying selected backup..."
upsun backup:get $BACKUP_ID -p $PROJECT -e $ENV || {
    echo "❌ Backup verification failed"
    exit 1
}

# Step 5: Notify team
echo "\n5. CRITICAL: Notifying team of disaster recovery..."
echo "Recovery started at $(date)"
echo "Restoring backup: $BACKUP_ID"

# Step 6: Perform restore
echo "\n6. Performing restore..."
read -p "Confirm restore (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Restore cancelled"
    exit 1
fi

upsun backup:restore $BACKUP_ID -p $PROJECT -e $ENV

# Step 7: Monitor recovery
echo "\n7. Monitoring recovery..."
upsun activity:list -p $PROJECT -e $ENV -i

# Step 8: Verify recovery
echo "\n8. Verifying environment recovery..."
sleep 60
upsun environment:url -p $PROJECT -e $ENV --primary

# Step 9: Test functionality
echo "\n9. Testing critical functionality..."
ENV_URL=$(upsun environment:url -p $PROJECT -e $ENV --primary --pipe)
HTTP_STATUS=$(curl -Is "$ENV_URL" | head -n 1)
echo "HTTP Status: $HTTP_STATUS"

# Step 10: Document recovery
echo "\n10. Documenting recovery..."
cat >> disaster-recovery-log.md <<EOF
## Recovery: $(date)
- **Backup restored**: $BACKUP_ID
- **Recovery time**: $SECONDS seconds
- **Status**: Success
- **Next steps**: Monitor, investigate root cause
EOF

echo "\n=== RECOVERY COMPLETE ==="
echo "Duration: $SECONDS seconds"
```

## Related Commands

**Environments:**
- `environment:info` - Check environment status
- `environment:sync` - Alternative to restore for code
- See [environments.md](environments.md)

**Deployments:**
- `environment:deploy` - Redeploy after restore
- See [deployments.md](deployments.md)

**Monitoring:**
- `activity:list` - Monitor restore activities
- `environment:logs` - Check post-restore logs
- See [development-tools.md](development-tools.md)

## Troubleshooting

**Backup creation fails:**
- Check disk space quota
- Verify backup retention limits
- Check for incomplete activities
- Try `--live` backup instead

**Restore takes too long:**
- Expected for large databases
- Check activity logs for progress
- Verify sufficient resources allocated
- Consider restore to smaller environment first

**Restore fails:**
- Check activity logs for errors
- Verify backup integrity
- Ensure target environment has capacity
- Check for resource conflicts

**Data inconsistency after restore:**
- Live backup may have inconsistencies
- Restore again with standard backup
- Check application logs for errors
- Verify database integrity

For more troubleshooting, see [troubleshooting.md](troubleshooting.md).
