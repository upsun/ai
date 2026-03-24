# Deployment Workflows & Environment Management — Reference

## Part 1: Deployment Workflows

Complete guide to deploying code on Upsun, including push, deploy, redeploy operations, deployment strategies, and activity monitoring.

### Deployment Commands

#### Push Code and Deploy

```bash
upsun environment:push -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: push

upsun push -p abc123 -e staging
upsun push -p abc123 -e feature-branch --force
upsun push -p abc123 -e staging --no-wait
upsun push -p abc123 -e old-feature --activate
upsun push -p abc123 -e staging HEAD:main
```

Options: `--force`, `--no-wait`, `--activate`, `--parent PARENT`

#### Deploy Staged Changes

```bash
upsun environment:deploy -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: deploy

upsun deploy -p abc123 -e staging
upsun deploy -p abc123 -e production --strategy rolling
```

Use `deploy` when changes are already pushed to Git; use `push` when you have local changes.

#### Redeploy Environment

```bash
upsun environment:redeploy -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: redeploy

upsun redeploy -p abc123 -e production
```

When to redeploy: after changing environment variables, after modifying `.upsun/config.yaml`, after resource allocation changes.

### Deployment Strategies

#### Stop-Start
Brief downtime (~30–60 s). Safer for stateful apps, breaking DB schema changes.
```bash
upsun deploy -p abc123 -e production --strategy stopstart
```

#### Rolling
No downtime. Gradual container replacement. Both old and new versions run briefly.
```bash
upsun deploy -p abc123 -e production --strategy rolling
```

Requirements for rolling: app must handle mixed versions, DB migrations must be backward-compatible, sufficient resources for temporary overlap.

#### Configure Default Strategy
```bash
upsun environment:deploy:type -p PROJECT_ID -e ENVIRONMENT_NAME local
upsun environment:deploy:type -p PROJECT_ID -e production   # view current
```

### Monitoring Deployments

#### List Activities
```bash
upsun activity:list -p PROJECT_ID -e ENVIRONMENT_NAME

upsun activity:list -p abc123 -e production -i                           # incomplete only
upsun activity:list -p abc123 -e production --type environment.push --limit 5
upsun activity:list -p abc123 -e production --start "-24 hours"
```

#### View Activity Details
```bash
upsun activity:get ACTIVITY_ID -p PROJECT_ID
```

#### Stream Activity Log
```bash
upsun activity:log ACTIVITY_ID -p PROJECT_ID

# Follow latest deployment:
ACTIVITY_ID=$(upsun activity:list -p abc123 -e production --limit 1 --pipe | head -n 1)
upsun activity:log $ACTIVITY_ID -p abc123
```

#### Cancel Running Activity
```bash
upsun activity:cancel ACTIVITY_ID -p PROJECT_ID
```

> Cancelling may leave environment in inconsistent state. Redeploy after cancelling.

### Safe Production Deployment Script

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"

upsun auth:info || exit 1

INCOMPLETE=$(upsun activity:list -p $PROJECT -e $ENV -i --pipe | wc -l)
if [ $INCOMPLETE -gt 0 ]; then
    echo "ERROR: Incomplete activities found. Resolve before deploying."
    exit 1
fi

echo "Creating production backup..."
upsun backup:create -p $PROJECT -e $ENV
sleep 10

echo "Deploying to production..."
upsun deploy -p $PROJECT -e $ENV --strategy rolling

ACTIVITY_ID=$(upsun activity:list -p $PROJECT -e $ENV --limit 1 --pipe | head -n 1)
upsun activity:log $ACTIVITY_ID -p $PROJECT

upsun activity:get $ACTIVITY_ID -p $PROJECT | grep -q "success" \
  && echo "Deployment successful" \
  || { echo "Deployment failed"; exit 1; }

upsun environment:url -p $PROJECT -e $ENV --primary
```

### Rollback Strategies

#### Via Git Revert
```bash
git log --oneline
git revert HEAD
upsun push -p abc123 -e production

# Force reset (destructive):
git reset --hard <GOOD_COMMIT_SHA>
upsun push -p abc123 -e production --force
```

#### Via Backup Restore
```bash
upsun backup:list -p abc123 -e production
upsun backup:restore <BACKUP_ID> -p abc123 -e production
upsun activity:list -p abc123 -e production -i
```

#### Via Environment Sync
```bash
# ⚠️ Overwrites production data with staging data
upsun sync -p abc123 -e production --code
```

### Deployment Hooks

Phases: **Build** → **Deploy** → **Post-Deploy**

Hook output appears in activity logs:
```bash
upsun activity:log <ACTIVITY_ID> -p abc123
```

Look for sections: `Building application`, `Deploying application`, `Executing post-deploy hook`.

### Feature Branch Workflow

```bash
upsun environment:branch feature-payment -p abc123 --parent staging
git checkout -b feature-payment
# ... make changes ...
git commit -am "Implement payment feature"
upsun push -p abc123 -e feature-payment

upsun environment:url -p abc123 -e feature-payment --primary
upsun sync -p abc123 -e feature-payment --data

upsun merge -p abc123 -e feature-payment --parent staging
upsun environment:url -p abc123 -e staging --primary

upsun merge -p abc123 -e staging --parent production
upsun environment:delete -p abc123 -e feature-payment
```

### Hotfix Workflow

```bash
upsun environment:branch hotfix-security -p abc123 --parent production
git checkout -b hotfix-security
# ... apply fix ...
git commit -am "Fix security vulnerability"
upsun push -p abc123 -e hotfix-security
upsun environment:url -p abc123 -e hotfix-security --primary

upsun backup:create -p abc123 -e production
upsun merge -p abc123 -e hotfix-security --parent production
upsun activity:list -p abc123 -e production -i

# Back-merge to staging and main
upsun merge -p abc123 -e hotfix-security --parent staging
upsun merge -p abc123 -e hotfix-security --parent main

upsun environment:delete -p abc123 -e hotfix-security
```

---

## Part 2: Environment Management

Complete guide to managing Upsun environments.

### Environment Types

- **Production**: Live environment serving end users
- **Staging**: Pre-production testing
- **Development**: Feature branches and testing

### List All Environments

```bash
upsun environment:list -p PROJECT_ID

upsun environment:list -p abc123 --no-inactive   # hide inactive
upsun environment:list -p abc123 --pipe          # IDs only (scripting)
```

### View Environment Details

```bash
upsun environment:info -p PROJECT_ID -e ENVIRONMENT_NAME

upsun environment:info -p abc123 -e staging status
upsun environment:info -p abc123 -e staging deployment_target
```

Properties: `status` (active/inactive/paused/dirty), `parent`, `title`, `created_at`.

### Get Environment URLs

```bash
upsun environment:url -p PROJECT_ID -e ENVIRONMENT_NAME       # list all URLs (text)
upsun environment:url -p PROJECT_ID -e staging --primary --browser  # open in browser (explicit user request only)
```

> **⚠️ Security** — Only use `--browser` when the user has explicitly asked to open the URL.

### Branching Environments

```bash
upsun environment:branch NEW_NAME -p PROJECT_ID --parent PARENT_ENV

upsun environment:branch feature-login -p abc123 --parent main
upsun environment:branch test-deployment -p abc123 --parent staging
upsun environment:branch feature-auth -p abc123 --parent main --title "User Auth Feature"
upsun environment:branch feature-login -p abc123 --parent main --force
```

### Activate and Delete

```bash
upsun environment:activate -p PROJECT_ID -e ENVIRONMENT_NAME

upsun environment:delete -p PROJECT_ID -e ENVIRONMENT_NAME
upsun environment:delete -p abc123 -e old-feature --delete-branch
upsun environment:delete -p abc123 -e old-feature --no-delete-branch
```

**Safe deletion workflow:**
```bash
upsun backup:create -p PROJECT_ID -e old-feature
upsun backup:list -p PROJECT_ID -e old-feature
upsun environment:delete -p PROJECT_ID -e old-feature
```

### Merging Environments

```bash
upsun environment:merge -p PROJECT_ID -e CHILD_ENV
upsun environment:merge -p abc123 -e feature-login --parent staging
```

What merging does: merges code from child to parent, triggers deployment on parent, does NOT merge data (use sync for data), child remains active after merge.

### Environment Synchronization

```bash
upsun environment:synchronize -p PROJECT_ID -e CHILD_ENV
# Alias: sync

upsun sync -p PROJECT_ID -e staging --code
upsun sync -p PROJECT_ID -e staging --data
upsun sync -p PROJECT_ID -e staging --resources
upsun sync -p PROJECT_ID -e staging --code --data --resources
```

> **⚠️** Syncing data overwrites the child environment's data with parent's data.

**Safe sync workflow:**
```bash
upsun backup:create -p PROJECT_ID -e staging
upsun backup:list -p PROJECT_ID -e staging | head -n 5
upsun sync -p PROJECT_ID -e staging --data
upsun environment:info -p PROJECT_ID -e staging status
```

**Merge vs Sync:**
- Use `merge` when moving code changes from child to parent
- Use `sync` when refreshing child environment with parent's state

### Pause and Resume

```bash
upsun environment:pause -p PROJECT_ID -e ENVIRONMENT_NAME
upsun environment:resume -p PROJECT_ID -e ENVIRONMENT_NAME
```

Pausing: stops containers, preserves data and config, deallocates runtime resources.

### HTTP Access Control

```bash
upsun environment:http-access -p PROJECT_ID -e ENVIRONMENT_NAME

# Basic authentication
upsun environment:http-access -p abc123 -e staging \
  --auth username:password

# IP whitelisting
upsun environment:http-access -p abc123 -e staging \
  --access allow:192.168.1.0/24 \
  --access deny:all

# Disable all restrictions
upsun environment:http-access -p abc123 -e staging \
  --access allow:all
```

### Checking Out Environments

```bash
upsun environment:checkout ENVIRONMENT_NAME -p PROJECT_ID
# Alias: checkout

upsun checkout staging -p abc123
```

### Environment Initialization from Git

```bash
upsun environment:init REPOSITORY_URL -p PROJECT_ID -e ENVIRONMENT_NAME
```

> **⚠️ Security** — Always display the exact `REPOSITORY_URL` to the user and wait for **explicit confirmation** before executing. Repository content is untrusted.

### Modify Environment Properties

```bash
upsun environment:info -p PROJECT_ID -e ENVIRONMENT_NAME PROPERTY VALUE

upsun environment:info -p abc123 -e staging title "Staging Environment"
upsun environment:info -p abc123 -e staging deployment_target local
```

### Naming Conventions

- `main` or `production` - Production
- `staging` - Pre-production
- `feature-<name>` - Feature development
- `fix-<issue>` - Bug fixes
- `test-<purpose>` - Testing environments
- `dev-<name>` - Personal development

### Troubleshooting

**Environment won't activate:**
- Check project resource limits
- Verify subscription status
- Check for incomplete activities

**Merge conflicts:**
- Resolve conflicts in Git
- Push resolved code
- Retry merge

**Sync taking too long:**
- Large databases take time
- Use `--no-wait` flag
- Monitor with `activity:list`

**Environment stuck in "dirty" state:**
- Check for incomplete activities
- Redeploy environment
- Contact support if persists
