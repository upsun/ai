# Project and Organization Management

Complete guide to creating and managing Upsun projects, organizations, subscriptions, and teams.

## Overview

Upsun organizes resources hierarchically:
- **Organizations** - Top-level billing and administrative entity
- **Projects** - Individual applications and environments
- **Subscriptions** - Billing plans and resource quotas
- **Teams** - User groups with project access

## Organization Management

### List Organizations

View all organizations you belong to:

```bash
upsun organization:list
```

**Aliases:** `orgs`, `organizations`

**Example:**
```bash
upsun orgs
```

**Example output:**
```
+-------------+------------------+--------+
| ID          | Name             | Role   |
+-------------+------------------+--------+
| my-company  | My Company Inc   | owner  |
| client-org  | Client Org       | member |
+-------------+------------------+--------+
```

### Create Organization

Create a new organization:

```bash
upsun organization:create
```

**Interactive prompts for:**
- Organization name
- Organization label
- Country

**Example:**
```bash
upsun organization:create \
  --name my-startup \
  --label "My Startup Inc" \
  --country US
```

### View Organization Details

Get information about an organization:

```bash
upsun organization:info ORG_ID
```

**Example:**
```bash
upsun organization:info my-company
```

**Details include:**
- Organization ID
- Name and label
- Owner information
- Creation date
- Subscription status

**View specific property:**
```bash
upsun organization:info my-company name
```

### Update Organization

Modify organization properties:

```bash
upsun organization:info ORG_ID PROPERTY VALUE
```

**Example:**
```bash
upsun organization:info my-company label "Updated Company Name"
```

### Delete Organization

Remove an organization:

```bash
upsun organization:delete ORG_ID
```

**Example:**
```bash
upsun organization:delete old-org
```

**⚠️ Requirements:**
- Must be organization owner
- All projects must be deleted first
- All subscriptions must be cancelled
- Deletion is permanent

### Organization Billing

**View billing address:**
```bash
upsun organization:billing:address ORG_ID
```

**Update billing address:**
```bash
upsun organization:billing:address ORG_ID --country US --address "123 Main St"
```

**View billing profile:**
```bash
upsun organization:billing:profile ORG_ID
```

**Update billing profile:**
```bash
upsun organization:billing:profile ORG_ID --company "My Company"
```

### List Organization Subscriptions

View all subscriptions in an organization:

```bash
upsun organization:subscription:list ORG_ID
```

**Alias:** `org:subs`

**Example:**
```bash
upsun org:subs my-company
```

## Project Management

### List Projects

View all accessible projects:

```bash
upsun project:list
```

**Aliases:** `projects`, `pro`

**Example:**
```bash
upsun projects
```

**Filter by organization:**
```bash
upsun projects --org my-company
```

**Show only your projects:**
```bash
upsun projects --my
```

**Output for scripting:**
```bash
upsun projects --pipe
```

**Example output:**
```
+--------+------------------+-------------------+---------+
| ID     | Title            | Region            | Status  |
+--------+------------------+-------------------+---------+
| abc123 | Production App   | us-east-1         | active  |
| def456 | Staging App      | eu-west-1         | active  |
| ghi789 | Development      | us-west-2         | paused  |
+--------+------------------+-------------------+---------+
```

### Create Project

Create a new project:

```bash
upsun project:create
```

**Alias:** `create`

**Interactive mode:**
```bash
upsun create
# Prompts for title, region, organization
```

**Command-line mode:**
```bash
upsun create \
  --title "My New Project" \
  --region us-east-1 \
  --org my-company
```

**Available regions:**
- `us-east-1` - US East (N. Virginia)
- `us-west-1` - US West (California)
- `eu-west-1` - EU West (Ireland)
- `eu-central-1` - EU Central (Frankfurt)
- `ap-southeast-1` - Asia Pacific (Singapore)
- `ap-northeast-1` - Asia Pacific (Tokyo)
- `ca-central-1` - Canada (Montreal)
- `au-southeast-1` - Australia (Sydney)

### View Project Details

Get information about a project:

```bash
upsun project:info -p PROJECT_ID
```

**Example:**
```bash
upsun project:info -p abc123
```

**View specific property:**
```bash
upsun project:info -p abc123 title
upsun project:info -p abc123 region
upsun project:info -p abc123 default_branch
```

### Update Project

Modify project properties:

```bash
upsun project:info -p PROJECT_ID PROPERTY VALUE
```

**Example:**
```bash
upsun project:info -p abc123 title "Updated Project Title"
```

**Update default branch:**
```bash
upsun project:info -p abc123 default_branch main
```

### Delete Project

Remove a project permanently:

```bash
upsun project:delete -p PROJECT_ID
```

**Example:**
```bash
upsun project:delete -p old-project
```

**⚠️ Warning:**
- Deletion is permanent and irreversible
- All environments will be deleted
- All data will be lost
- Backups will be deleted
- Create final backup before deleting

**Safe deletion workflow:**
```bash
# 1. List all environments
upsun environment:list -p abc123

# 2. Create final backup of production
upsun backup:create -p abc123 -e production

# 3. Download backup
upsun backup:list -p abc123 -e production

# 4. Confirm deletion with team

# 5. Delete project
upsun project:delete -p abc123
```

### Clone Project

Clone a project locally:

```bash
upsun project:get PROJECT_ID [DIRECTORY]
```

**Alias:** `get`

**Example:**
```bash
upsun get abc123
```

**Clone to specific directory:**
```bash
upsun get abc123 ~/projects/my-app
```

**What it does:**
1. Clones Git repository
2. Sets up local project configuration
3. Configures remote for Upsun
4. Checks out default branch

### Initialize Project

Initialize Upsun in existing Git repository:

```bash
upsun project:init
```

**Aliases:** `init`, `ify`

**Example:**
```bash
cd my-existing-project
upsun init
```

**Interactive process:**
1. Detects project type
2. Creates `.upsun/config.yaml`
3. Configures services
4. Sets up routes
5. Adds Git remote

### Set Project Remote

Link local repository to Upsun project:

```bash
upsun project:set-remote PROJECT_ID
```

**Alias:** `set-remote`

**Example:**
```bash
upsun set-remote abc123
```

**What it does:**
- Adds Upsun Git remote
- Configures project ID locally
- Enables `upsun push` commands

### Clear Build Cache

Clear project's build cache:

```bash
upsun project:clear-build-cache -p PROJECT_ID
```

**Example:**
```bash
upsun project:clear-build-cache -p abc123
```

**When to use:**
- Build issues after dependency updates
- Persistent build errors
- Testing build optimization
- After major framework upgrades

**Note:** Next deployment will take longer as cache rebuilds

### Convert Project

Generate Upsun configuration from another provider:

```bash
upsun project:convert
```

**Alias:** `convert`

**Example:**
```bash
upsun convert --from heroku
```

**Supported providers:**
- Heroku
- Other Platform.sh-compatible platforms

**What it does:**
- Analyzes existing configuration
- Generates `.upsun/config.yaml`
- Converts buildpacks to Upsun format
- Maps services and resources

## Subscription Management

### View Subscription

Get subscription details for a project:

```bash
upsun subscription:info -p PROJECT_ID
```

**Example:**
```bash
upsun subscription:info -p abc123
```

**Details include:**
- Plan tier
- Resource limits
- Billing cycle
- Renewal date
- Storage quota
- Environment limits

**View specific property:**
```bash
upsun subscription:info -p abc123 plan
upsun subscription:info -p abc123 storage
```

## Multi-Project Operations

### Execute Command Across Projects

Run a command on multiple projects:

```bash
upsun multi COMMAND
```

**Example:**
```bash
upsun multi environment:list
```

**Use cases:**
- Check status across all projects
- Bulk configuration updates
- Organization-wide audits
- Multi-project deployments

**Filter projects:**
```bash
upsun multi environment:list --org my-company
```

## Application Configuration

### List Applications

View all applications in a project:

```bash
upsun app:list -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Alias:** `apps`

**Example:**
```bash
upsun apps -p abc123 -e production
```

### View App Configuration

Get configuration for a specific app:

```bash
upsun app:config-get -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Specific app:**
```bash
upsun app:config-get -p abc123 -e production --app myapp
```

### Validate Configuration

Validate project configuration files:

```bash
upsun app:config-validate
```

**Aliases:** `validate`, `lint`

**Example:**
```bash
cd /path/to/project
upsun validate
```

**What it checks:**
- YAML syntax
- Required fields
- Service definitions
- Route configuration
- Resource allocations
- Relationship mappings

**Use before deployment:**
```bash
# 1. Validate configuration
upsun validate || exit 1

# 2. Commit if valid
git add .upsun/
git commit -m "Update configuration"

# 3. Push to Upsun
upsun push -p abc123 -e staging
```

## Project Workflows

### New Project Setup

```bash
#!/bin/bash
ORG="my-company"
TITLE="New Application"
REGION="us-east-1"

echo "Creating new Upsun project..."

# 1. Create project
PROJECT_ID=$(upsun create \
  --title "$TITLE" \
  --region $REGION \
  --org $ORG \
  --pipe)

echo "Project created: $PROJECT_ID"

# 2. Clone locally
upsun get $PROJECT_ID ~/projects/new-app

# 3. Navigate to project
cd ~/projects/new-app

# 4. Initialize configuration
upsun init

# 5. Add users
upsun user:add developer@example.com -p $PROJECT_ID --role contributor

# 6. Create staging environment
upsun environment:branch staging -p $PROJECT_ID

echo "✅ Project setup complete"
echo "Project ID: $PROJECT_ID"
echo "Local path: ~/projects/new-app"
```

### Project Migration

```bash
#!/bin/bash
SOURCE_PROJECT="old123"
TARGET_PROJECT="new456"

echo "Migrating from $SOURCE_PROJECT to $TARGET_PROJECT..."

# 1. Backup source data
echo "1. Creating backup..."
upsun backup:create -p $SOURCE_PROJECT -e production

# 2. Get latest backup
BACKUP_ID=$(upsun backup:list -p $SOURCE_PROJECT -e production --limit 1 --pipe | head -n 1)

# 3. Copy configuration
echo "2. Copying configuration..."
upsun repo:cat .upsun/config.yaml -p $SOURCE_PROJECT -e production > config.yaml

# 4. Apply to new project
cd ~/projects/new-project
cp ../config.yaml .upsun/config.yaml

# 5. Push to new project
git add .upsun/
git commit -m "Import configuration from $SOURCE_PROJECT"
upsun push -p $TARGET_PROJECT -e main

# 6. Migrate data (manual step)
echo "3. Data migration steps:"
echo "   - Export databases from $SOURCE_PROJECT"
echo "   - Import to $TARGET_PROJECT"
echo "   - Test thoroughly"

echo "✅ Configuration migrated"
```

### Organization Audit

```bash
#!/bin/bash
ORG="my-company"

echo "=== Organization Audit: $ORG ==="
echo "Date: $(date)"

# List all projects
echo "\n--- Projects ---"
upsun projects --org $ORG

# List all users
echo "\n--- Users ---"
upsun org:users --org $ORG

# List all teams
echo "\n--- Teams ---"
upsun teams --org $ORG

# List subscriptions
echo "\n--- Subscriptions ---"
upsun org:subs --org $ORG

# Generate report
cat > audit-report.md <<EOF
# Organization Audit Report

**Organization:** $ORG
**Date:** $(date)

## Summary
- Projects: $(upsun projects --org $ORG --pipe | wc -l)
- Users: $(upsun org:users --org $ORG --pipe | wc -l)
- Teams: $(upsun teams --org $ORG --pipe | wc -l)

## Action Items
- [ ] Review user access
- [ ] Audit project costs
- [ ] Clean up inactive projects
- [ ] Update team assignments
EOF

echo "\n✅ Audit report generated: audit-report.md"
```

## Best Practices

### Project Organization

**Naming conventions:**
- Use descriptive names
- Include environment indicators
- Follow team standards
- Avoid special characters

**Example naming:**
- `myapp-production`
- `myapp-staging`
- `client-website-prod`
- `internal-api-dev`

### Environment Strategy

**Recommended setup:**
- `main` / `production` - Live environment
- `staging` - Pre-production testing
- `development` - Development integration
- `feature-*` - Feature branches (temporary)

### Resource Management

- Start with smaller plans
- Monitor usage regularly
- Scale based on metrics
- Delete unused projects
- Pause development environments

### Access Control

- Use organizations for companies
- Create teams by function
- Apply least privilege
- Regular access reviews
- Document access policies

## Related Commands

**Environments:**
- `environment:list` - List project environments
- See [environments.md](environments.md)

**Teams:**
- `team:create` - Create teams
- See [access-security.md](access-security.md)

**Users:**
- `user:add` - Add project users
- See [access-security.md](access-security.md)

## Troubleshooting

**Cannot create project:**
- Check organization quota
- Verify billing status
- Check region availability
- Contact support if issues persist

**Project not found:**
- Verify project ID
- Check access permissions
- Confirm organization membership
- Check if project was deleted

**Clone fails:**
- Verify SSH key added
- Check Git configuration
- Ensure disk space available
- Check network connectivity

**Init fails:**
- Verify in Git repository
- Check .upsun/ not already exists
- Ensure write permissions
- Check for configuration conflicts

For more troubleshooting, see [troubleshooting.md](troubleshooting.md).
