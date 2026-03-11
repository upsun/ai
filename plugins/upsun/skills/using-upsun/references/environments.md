# Environment Management

Complete guide to managing Upsun environments including lifecycle operations, branching, merging, and synchronization.

## Overview

Environments in Upsun represent different versions of your application. Each environment has its own codebase, data, and resources. Environments are organized in a tree structure where child environments inherit from parent environments.

**Environment Types:**
- **Production**: The live environment serving end users
- **Staging**: Pre-production testing environment
- **Development**: Feature branches and testing environments

## Common Workflows

### List All Environments

View all environments in a project:

```bash
upsun environment:list -p PROJECT_ID
```

**Useful options:**
- `--no-inactive` - Hide inactive environments
- `--pipe` - Output environment IDs only (for scripting)

**Example output:**
```
Your environments are:
+---------------+----------------+--------+
| ID            | Title          | Status |
+---------------+----------------+--------+
| main          | Main           | Active |
| staging       | Staging        | Active |
| feature-auth  | Feature Auth   | Active |
| old-feature   | Old Feature    | Inactive |
+---------------+----------------+--------+
```

### View Environment Details

Get detailed information about a specific environment:

```bash
upsun environment:info -p PROJECT_ID -e ENVIRONMENT_NAME
```

**View specific property:**
```bash
upsun environment:info -p PROJECT_ID -e staging status
upsun environment:info -p PROJECT_ID -e staging deployment_target
```

**Common properties:**
- `status` - active, inactive, paused, dirty
- `deployment_target` - The deployment configuration
- `parent` - Parent environment ID
- `title` - Environment title
- `created_at` - Creation timestamp

### Get Environment URLs

Retrieve public URLs for an environment:

```bash
upsun environment:url -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Open primary URL in browser:**
```bash
upsun environment:url -p PROJECT_ID -e staging --primary --browser
```

**List all URLs:**
```bash
upsun environment:url -p PROJECT_ID -e staging
```

## Branching Environments

### Create New Branch Environment

Create a new environment by branching from an existing one:

```bash
upsun environment:branch NEW_NAME -p PROJECT_ID --parent PARENT_ENV
```

**Examples:**

**Branch from main for feature development:**
```bash
upsun environment:branch feature-login -p abc123 --parent main
```

**Branch from staging for testing:**
```bash
upsun environment:branch test-deployment -p abc123 --parent staging
```

**With custom title:**
```bash
upsun environment:branch feature-auth -p abc123 --parent main --title "User Authentication Feature"
```

**Force branch creation (if environment exists):**
```bash
upsun environment:branch feature-login -p abc123 --parent main --force
```

### Branch Workflow Best Practices

1. **Name branches descriptively**: Use prefixes like `feature-`, `fix-`, `test-`
2. **Branch from appropriate parent**: Development from staging, hotfixes from production
3. **Set meaningful titles**: Helps team members understand the environment purpose
4. **Clean up old branches**: Delete inactive environments regularly

## Environment Activation and Deletion

### Activate an Environment

Reactivate a previously deactivated environment:

```bash
upsun environment:activate -p PROJECT_ID -e ENVIRONMENT_NAME
```

**What activation does:**
- Restores environment to active state
- Allocates resources
- Makes environment accessible
- Resumes deployments

### Delete an Environment

Delete an environment permanently:

```bash
upsun environment:delete -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Delete with Git branch:**
```bash
upsun environment:delete -p PROJECT_ID -e old-feature --delete-branch
```

**Delete without deleting Git branch:**
```bash
upsun environment:delete -p PROJECT_ID -e old-feature --no-delete-branch
```

**⚠️ Warning**: Deletion is permanent. Create a backup first if you need to preserve data.

**Safe deletion workflow:**
```bash
# 1. Create backup
upsun backup:create -p PROJECT_ID -e old-feature

# 2. Verify backup exists
upsun backup:list -p PROJECT_ID -e old-feature

# 3. Delete environment
upsun environment:delete -p PROJECT_ID -e old-feature
```

## Merging Environments

### Merge Environment to Parent

Merge changes from a child environment into its parent:

```bash
upsun environment:merge -p PROJECT_ID -e CHILD_ENV
```

**Merge with specific parent:**
```bash
upsun environment:merge -p PROJECT_ID -e feature-login --parent staging
```

**What merging does:**
1. Merges code from child to parent
2. Triggers deployment on parent environment
3. Does NOT merge data (use sync for data)
4. Child environment remains active after merge

**Typical merge workflow:**

```bash
# 1. Ensure feature branch is deployed and tested
upsun environment:deploy -p PROJECT_ID -e feature-login

# 2. Verify feature works correctly
upsun environment:url -p PROJECT_ID -e feature-login --primary --browser

# 3. Merge to staging
upsun environment:merge -p PROJECT_ID -e feature-login --parent staging

# 4. Monitor merge activity
upsun activity:list -p PROJECT_ID -e staging -i

# 5. Test on staging
upsun environment:url -p PROJECT_ID -e staging --primary --browser

# 6. If successful, delete feature branch
upsun environment:delete -p PROJECT_ID -e feature-login
```

## Environment Synchronization

### Sync from Parent Environment

Synchronize code, data, or resources from parent to child environment:

```bash
upsun environment:synchronize -p PROJECT_ID -e CHILD_ENV
```

**Sync options:**

**Sync code only:**
```bash
upsun sync -p PROJECT_ID -e staging --code
```

**Sync data only (databases, files):**
```bash
upsun sync -p PROJECT_ID -e staging --data
```

**Sync resources only (configuration):**
```bash
upsun sync -p PROJECT_ID -e staging --resources
```

**Sync everything:**
```bash
upsun sync -p PROJECT_ID -e staging --code --data --resources
```

**⚠️ Warning**: Syncing data will overwrite the child environment's data with parent's data.

**Safe sync workflow:**

```bash
# 1. Create backup before sync
upsun backup:create -p PROJECT_ID -e staging

# 2. Verify backup created
upsun backup:list -p PROJECT_ID -e staging | head -n 5

# 3. Sync from parent
upsun sync -p PROJECT_ID -e staging --data

# 4. Monitor sync activity
upsun activity:log <ACTIVITY_ID>

# 5. Verify sync completed successfully
upsun environment:info -p PROJECT_ID -e staging status
```

### When to Use Sync vs Merge

**Use `merge`** when:
- You want to move code changes from child to parent
- You're promoting a feature from development to staging/production
- You only need code, not data

**Use `sync`** when:
- You want to refresh child environment with parent's state
- You need production data in staging for testing
- You want to ensure environments are identical

## Pause and Resume

### Pause an Environment

Pause an environment to save costs while preserving data:

```bash
upsun environment:pause -p PROJECT_ID -e ENVIRONMENT_NAME
```

**What pausing does:**
- Stops all running containers
- Preserves data and configuration
- Deallocates runtime resources
- Maintains environment metadata
- Environment becomes inaccessible

**When to pause:**
- Temporary environments not currently in use
- Development environments during off-hours
- Cost optimization for infrequently used environments

### Resume a Paused Environment

Resume a paused environment:

```bash
upsun environment:resume -p PROJECT_ID -e ENVIRONMENT_NAME
```

**What resuming does:**
- Allocates resources
- Starts containers
- Makes environment accessible
- May take several minutes depending on environment size

**Pause/resume workflow:**

```bash
# Pause environment at end of workday
upsun environment:pause -p PROJECT_ID -e dev-testing

# Resume in the morning
upsun environment:resume -p PROJECT_ID -e dev-testing

# Wait for resume to complete
upsun activity:list -p PROJECT_ID -e dev-testing -i

# Verify environment is accessible
upsun environment:url -p PROJECT_ID -e dev-testing --primary --browser
```

## HTTP Access Control

### Configure HTTP Access

Control HTTP access to an environment with basic authentication or IP whitelisting:

```bash
upsun environment:http-access -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Enable basic authentication:**
```bash
upsun environment:http-access -p PROJECT_ID -e staging \
  --auth username:password
```

**IP whitelisting:**
```bash
upsun environment:http-access -p PROJECT_ID -e staging \
  --access allow:192.168.1.0/24 \
  --access deny:all
```

**Disable all restrictions:**
```bash
upsun environment:http-access -p PROJECT_ID -e staging \
  --access allow:all
```

**Use cases:**
- Protect staging environments from public access
- Restrict development environments to office IP ranges
- Add authentication layer before application-level auth

## Checking Out Environments

### Checkout Environment Locally

Switch your local Git repository to track a different environment:

```bash
upsun environment:checkout ENVIRONMENT_NAME -p PROJECT_ID
```

**Example:**
```bash
# Checkout staging environment
upsun checkout staging -p abc123

# Make changes and push
git commit -am "Update feature"
upsun push -p abc123 -e staging
```

**What checkout does:**
- Switches Git branch to match environment
- Updates local working directory
- Sets environment as default for CLI commands

## Environment Initialization

### Initialize from Git Repository

Initialize an environment from a public Git repository:

```bash
upsun environment:init REPOSITORY_URL -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example:**
```bash
upsun environment:init https://github.com/user/repo.git \
  -p abc123 -e new-env
```

**Use cases:**
- Import existing project into Upsun
- Bootstrap environment from template repository
- Migrate from another platform

## Environment Properties

### Modify Environment Properties

Set or update environment properties:

```bash
upsun environment:info -p PROJECT_ID -e ENVIRONMENT_NAME PROPERTY VALUE
```

**Common modifiable properties:**

**Update environment title:**
```bash
upsun environment:info -p PROJECT_ID -e staging title "Staging Environment"
```

**Set deployment target:**
```bash
upsun environment:info -p PROJECT_ID -e staging deployment_target local
```

## Best Practices

### Environment Naming Conventions

**Recommended patterns:**
- `main` or `production` - Production environment
- `staging` - Pre-production testing
- `feature-<name>` - Feature development (e.g., `feature-authentication`)
- `fix-<issue>` - Bug fixes (e.g., `fix-login-error`)
- `test-<purpose>` - Testing environments (e.g., `test-performance`)
- `dev-<name>` - Personal development (e.g., `dev-alice`)

### Environment Lifecycle

**Recommended workflow:**

1. **Create** - Branch from appropriate parent
2. **Develop** - Make changes, deploy, test
3. **Sync** - Refresh with parent data if needed
4. **Test** - Verify functionality
5. **Merge** - Promote code to parent
6. **Delete** or **Pause** - Clean up when done

### Resource Management

**Cost optimization:**
- Delete unused environments
- Pause infrequently used environments
- Use smaller resource profiles for development
- Limit number of active environments

### Safety Practices

**Before destructive operations:**
1. Create backups
2. Verify backups exist
3. Communicate with team
4. Document the operation
5. Have rollback plan ready

## Related Commands

**Deployments:**
- `environment:push` - Push code and deploy
- `environment:deploy` - Deploy staged changes
- `environment:redeploy` - Redeploy current code
- See [deployments.md](deployments.md)

**Backups:**
- `backup:create` - Create environment backup
- `backup:list` - List available backups
- `backup:restore` - Restore from backup
- See [backups.md](backups.md)

**Monitoring:**
- `activity:list` - View environment activities
- `environment:logs` - Access environment logs
- `metrics:all` - View performance metrics
- See [development-tools.md](development-tools.md)

**Resources:**
- `resources:get` - View resource allocation
- `autoscaling:get` - View autoscaling configuration
- See [resources-scaling.md](resources-scaling.md)

## Troubleshooting

**Environment won't activate:**
- Check project resource limits
- Verify subscription status
- Check for incomplete activities

**Merge conflicts:**
- Resolve conflicts in Git
- Push resolved code to environment
- Retry merge

**Sync taking too long:**
- Large databases take time
- Use `--no-wait` flag for async operation
- Monitor with `activity:list`

**Environment stuck in "dirty" state:**
- Check for incomplete activities
- Redeploy environment
- Contact support if persists

For more troubleshooting, see [troubleshooting.md](troubleshooting.md).
