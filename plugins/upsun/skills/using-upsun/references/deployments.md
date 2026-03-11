# Deployment Workflows

Complete guide to deploying code on Upsun, including push, deploy, redeploy operations, deployment strategies, and activity monitoring.

## Overview

Upsun supports multiple deployment workflows depending on your needs. Understanding the differences between `push`, `deploy`, and `redeploy` is crucial for efficient development.

**Key Concepts:**
- **Push** - Push local code to Upsun and trigger deployment
- **Deploy** - Deploy staged changes already on Upsun
- **Redeploy** - Redeploy current code (useful for config changes)
- **Activity** - Every deployment creates an activity that can be monitored

## Deployment Commands

### Push Code and Deploy

Push local changes to an environment and trigger deployment:

```bash
upsun environment:push -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Common options:**
- `--force` - Force push even if not fast-forward
- `--no-wait` - Don't wait for deployment to complete
- `--activate` - Activate environment if inactive
- `--parent PARENT` - Set parent environment

**Examples:**

**Basic push to environment:**
```bash
upsun push -p abc123 -e staging
```

**Force push (use with caution):**
```bash
upsun push -p abc123 -e feature-branch --force
```

**Push without waiting:**
```bash
upsun push -p abc123 -e staging --no-wait
```

**Push and activate inactive environment:**
```bash
upsun push -p abc123 -e old-feature --activate
```

**Push specific source:**
```bash
upsun push -p abc123 -e staging HEAD:main
```

### Deploy Staged Changes

Deploy changes that are already staged on Upsun:

```bash
upsun environment:deploy -p PROJECT_ID -e ENVIRONMENT_NAME
```

**When to use deploy vs push:**
- Use `deploy` when changes are already pushed to Git
- Use `deploy` after configuration changes in Console
- Use `deploy` to trigger deployment without code changes
- Use `push` when you have local changes to deploy

**Deploy with specific strategy:**
```bash
upsun deploy -p abc123 -e production --strategy rolling
```

**Deployment strategies:**
- `stopstart` - Stop current deployment, start new one (brief downtime)
- `rolling` - Gradual replacement of containers (zero downtime)

**Example workflow:**

```bash
# 1. Push to Git directly (not through Upsun CLI)
git push origin staging

# 2. Deploy the pushed changes
upsun deploy -p abc123 -e staging

# 3. Monitor deployment
upsun activity:list -p abc123 -e staging -i
```

### Redeploy Environment

Redeploy the current code without changes:

```bash
upsun environment:redeploy -p PROJECT_ID -e ENVIRONMENT_NAME
```

**When to redeploy:**
- After changing environment variables
- After modifying `.upsun/config.yaml`
- After resource allocation changes
- To rebuild with updated dependencies
- To recover from failed deployment

**Examples:**

**Basic redeploy:**
```bash
upsun redeploy -p abc123 -e production
```

**Redeploy after environment variable change:**
```bash
# 1. Update variable
upsun variable:update DATABASE_URL -p abc123 -e production --value "new_value"

# 2. Redeploy to apply changes
upsun redeploy -p abc123 -e production
```

## Deployment Strategies

### Stop-Start Deployment

**Characteristics:**
- Stops current containers first
- Starts new containers
- Brief downtime (typically 30-60 seconds)
- Safer for stateful applications
- Default for most environments

**Use when:**
- Downtime window is acceptable
- Breaking database schema changes
- Stateful application that can't run multiple versions

**Example:**
```bash
upsun deploy -p abc123 -e production --strategy stopstart
```

### Rolling Deployment

**Characteristics:**
- No downtime
- Gradual container replacement
- Both old and new versions run briefly
- Requires more resources temporarily

**Use when:**
- Zero downtime required
- Backward-compatible changes
- Stateless application
- Production deployments

**Example:**
```bash
upsun deploy -p abc123 -e production --strategy rolling
```

**Requirements for rolling deployments:**
1. Application must handle mixed versions
2. Database migrations must be backward-compatible
3. Sufficient resources for temporary overlap

### Configuring Default Strategy

Set default deployment strategy for an environment:

```bash
upsun environment:deploy:type -p PROJECT_ID -e ENVIRONMENT_NAME local
```

**View current deployment type:**
```bash
upsun environment:deploy:type -p PROJECT_ID -e production
```

## Monitoring Deployments

### List Activities

View recent activities for an environment:

```bash
upsun activity:list -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Useful options:**
- `-i, --incomplete` - Show only incomplete activities
- `--limit N` - Limit number of results
- `--type deploy` - Filter by activity type
- `--start DATE` - Show activities since date

**Examples:**

**View incomplete activities:**
```bash
upsun activity:list -p abc123 -e production -i
```

**View last 5 deployments:**
```bash
upsun activity:list -p abc123 -e production --type environment.push --limit 5
```

**View activities from last 24 hours:**
```bash
upsun activity:list -p abc123 -e production --start "-24 hours"
```

### View Activity Details

Get detailed information about a specific activity:

```bash
upsun activity:get ACTIVITY_ID -p PROJECT_ID
```

**Example:**
```bash
upsun activity:get 7vwjx5qzr3iko -p abc123
```

**Output includes:**
- Activity type and state
- Created and completed times
- Success/failure status
- Log summary
- Related commits

### View Activity Logs

Watch deployment logs in real-time:

```bash
upsun activity:log ACTIVITY_ID -p PROJECT_ID
```

**Examples:**

**View specific activity log:**
```bash
upsun activity:log 7vwjx5qzr3iko -p abc123
```

**Follow latest deployment:**
```bash
# Get latest activity ID
ACTIVITY_ID=$(upsun activity:list -p abc123 -e production --limit 1 --pipe | head -n 1)

# Follow its log
upsun activity:log $ACTIVITY_ID -p abc123
```

**Log output includes:**
- Build phase logs
- Deploy phase logs
- Post-deploy hook output
- Error messages
- Timing information

### Cancel Running Activity

Cancel an in-progress deployment:

```bash
upsun activity:cancel ACTIVITY_ID -p PROJECT_ID
```

**When to cancel:**
- Deployment stuck or frozen
- Wrong code deployed
- Need to rollback immediately
- Build taking too long

**Example:**
```bash
# Find incomplete activities
upsun activity:list -p abc123 -e staging -i

# Cancel specific activity
upsun activity:cancel 7vwjx5qzr3iko -p abc123
```

**⚠️ Warning**: Cancelling may leave environment in inconsistent state. Redeploy after cancelling.

## Safe Production Deployment

### Pre-Deployment Checklist

Before deploying to production:

1. **Test on staging:**
   ```bash
   upsun push -p abc123 -e staging
   upsun activity:log <ACTIVITY_ID> -p abc123
   ```

2. **Create production backup:**
   ```bash
   upsun backup:create -p abc123 -e production
   ```

3. **Verify no incomplete activities:**
   ```bash
   upsun activity:list -p abc123 -e production -i
   ```

4. **Check production health:**
   ```bash
   upsun environment:info -p abc123 -e production status
   upsun metrics:all -p abc123 -e production
   ```

5. **Notify team:**
   - Send deployment notification
   - Have rollback plan ready
   - Ensure monitoring is active

### Production Deployment Workflow

**Complete safe deployment:**

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"

# 1. Verify authentication
upsun auth:info || exit 1

# 2. Check for incomplete activities
INCOMPLETE=$(upsun activity:list -p $PROJECT -e $ENV -i --pipe | wc -l)
if [ $INCOMPLETE -gt 0 ]; then
    echo "ERROR: Incomplete activities found. Resolve before deploying."
    exit 1
fi

# 3. Create backup
echo "Creating production backup..."
upsun backup:create -p $PROJECT -e $ENV

# 4. Wait for backup to complete
sleep 10

# 5. Deploy with rolling strategy
echo "Deploying to production..."
upsun deploy -p $PROJECT -e $ENV --strategy rolling

# 6. Get activity ID
ACTIVITY_ID=$(upsun activity:list -p $PROJECT -e $ENV --limit 1 --pipe | head -n 1)

# 7. Monitor deployment
echo "Monitoring deployment: $ACTIVITY_ID"
upsun activity:log $ACTIVITY_ID -p $PROJECT

# 8. Verify deployment succeeded
upsun activity:get $ACTIVITY_ID -p $PROJECT | grep -q "success"
if [ $? -eq 0 ]; then
    echo "✅ Deployment successful"
else
    echo "❌ Deployment failed"
    exit 1
fi

# 9. Health check
echo "Running health check..."
upsun environment:url -p $PROJECT -e $ENV --primary
```

### Post-Deployment Verification

After deployment:

1. **Check deployment status:**
   ```bash
   upsun activity:get <ACTIVITY_ID> -p abc123
   ```

2. **Verify application is running:**
   ```bash
   upsun environment:url -p abc123 -e production --primary --browser
   ```

3. **Check logs for errors:**
   ```bash
   upsun logs -p abc123 -e production --tail
   ```

4. **Monitor metrics:**
   ```bash
   upsun metrics:all -p abc123 -e production
   ```

5. **Test critical functionality:**
   - Login/authentication
   - Database operations
   - External integrations
   - API endpoints

## Rollback Strategies

### Quick Rollback via Git

Rollback to previous commit:

```bash
# 1. Identify good commit
git log --oneline

# 2. Revert to previous commit
git revert HEAD

# 3. Push revert
upsun push -p abc123 -e production

# Alternative: Reset to specific commit (destructive)
git reset --hard <GOOD_COMMIT_SHA>
upsun push -p abc123 -e production --force
```

### Rollback via Backup Restore

Restore from backup (includes data):

```bash
# 1. List recent backups
upsun backup:list -p abc123 -e production

# 2. Restore specific backup
upsun backup:restore <BACKUP_ID> -p abc123 -e production

# 3. Monitor restore activity
upsun activity:list -p abc123 -e production -i
```

See [backups.md](backups.md) for detailed restore procedures.

### Rollback via Environment Sync

Sync from stable environment:

```bash
# If production failed, sync from staging (if staging is good)
# ⚠️ This will overwrite production data with staging data
upsun sync -p abc123 -e production --code
```

## Deployment Hooks

### Understanding Deployment Phases

Upsun deployments have multiple phases:

1. **Build** - Compile code, install dependencies
2. **Deploy** - Start services, run deploy hooks
3. **Post-Deploy** - Run post-deploy hooks

### Viewing Hook Output

Hook output appears in activity logs:

```bash
upsun activity:log <ACTIVITY_ID> -p abc123
```

**Look for sections:**
- `Building application` - Build hook output
- `Deploying application` - Deploy hook output
- `Executing post-deploy hook` - Post-deploy hook output

### Common Hook Issues

**Build hook fails:**
- Check dependency versions
- Verify build commands syntax
- Check disk space during build

**Deploy hook fails:**
- Database migrations timing out
- Service dependencies not ready
- Insufficient memory

**Post-deploy hook fails:**
- Cache clearing errors
- External service unavailable
- Permission issues

See [troubleshooting.md](troubleshooting.md) for solutions.

## Feature Branch Workflow

### Complete Feature Development Cycle

```bash
# 1. Create feature branch environment
upsun environment:branch feature-payment -p abc123 --parent staging

# 2. Develop locally and push
git checkout -b feature-payment
# ... make changes ...
git commit -am "Implement payment feature"
upsun push -p abc123 -e feature-payment

# 3. Test on feature environment
upsun environment:url -p abc123 -e feature-payment --primary --browser

# 4. Sync data from staging if needed
upsun sync -p abc123 -e feature-payment --data

# 5. Once tested, merge to staging
upsun merge -p abc123 -e feature-payment --parent staging

# 6. Test on staging
upsun environment:url -p abc123 -e staging --primary --browser

# 7. If successful, merge staging to production
upsun merge -p abc123 -e staging --parent production

# 8. Clean up feature environment
upsun environment:delete -p abc123 -e feature-payment
```

## Hotfix Workflow

### Emergency Production Fix

```bash
# 1. Create hotfix branch from production
upsun environment:branch hotfix-security -p abc123 --parent production

# 2. Apply fix and push
git checkout -b hotfix-security
# ... apply fix ...
git commit -am "Fix security vulnerability"
upsun push -p abc123 -e hotfix-security

# 3. Test hotfix environment
upsun environment:url -p abc123 -e hotfix-security --primary --browser

# 4. Create production backup
upsun backup:create -p abc123 -e production

# 5. Merge hotfix to production
upsun merge -p abc123 -e hotfix-security --parent production

# 6. Monitor production deployment
upsun activity:list -p abc123 -e production -i

# 7. Verify fix
upsun environment:url -p abc123 -e production --primary --browser

# 8. Back-merge to staging and main
upsun merge -p abc123 -e hotfix-security --parent staging
upsun merge -p abc123 -e hotfix-security --parent main

# 9. Clean up hotfix environment
upsun environment:delete -p abc123 -e hotfix-security
```

## Best Practices

### Deployment Timing

**Consider:**
- Deploy during low-traffic periods
- Avoid deployments before weekends/holidays
- Have team available for monitoring
- Communicate deployment windows

### Testing Before Production

**Always:**
1. Test on development environment
2. Test on staging with production-like data
3. Run automated tests
4. Perform manual testing
5. Get stakeholder approval

### Monitoring

**During deployment:**
- Watch activity logs
- Monitor application logs
- Check metrics (CPU, memory, response time)
- Test critical user flows
- Have rollback plan ready

### Documentation

**Document:**
- What was deployed
- Why it was deployed
- Any known issues
- Rollback procedure
- Post-deployment tasks

## Related Commands

**Environments:**
- `environment:branch` - Create feature branches
- `environment:merge` - Merge environments
- `environment:sync` - Sync from parent
- See [environments.md](environments.md)

**Backups:**
- `backup:create` - Backup before deployment
- `backup:restore` - Rollback via restore
- See [backups.md](backups.md)

**Monitoring:**
- `environment:logs` - View application logs
- `metrics:all` - Monitor performance
- See [development-tools.md](development-tools.md)

## Troubleshooting

**Deployment stuck:**
- Check activity logs for errors
- Cancel and redeploy
- Check resource limits

**Build fails:**
- Review build hook logs
- Check dependency versions
- Verify disk space
- Clear build cache: `project:clear-build-cache`

**Deploy succeeds but app broken:**
- Check environment variables
- Review deploy hook logs
- Check service relationships
- Verify database migrations

**Deployment very slow:**
- Check network connectivity
- Review resource allocation
- Consider build cache optimization
- Check for large dependencies

For more troubleshooting, see [troubleshooting.md](troubleshooting.md).
