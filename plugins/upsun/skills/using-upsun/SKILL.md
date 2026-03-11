---
name: upsun
description: This skill should be used when the user asks to "deploy to Upsun", "create Upsun environment", "manage Upsun project", "backup Upsun", "check Upsun status", "sync environment", "merge branch", "scale resources", "configure domain", "manage database", "check logs", "create tunnel", or mentions Upsun CLI commands, environment management, deployment workflows, backup/restore operations, resource scaling, or Upsun project administration.
version: 1.0.0
---

# Upsun CLI Management Skill

Comprehensive skill for managing Upsun Platform-as-a-Service projects using the Upsun CLI (v5.6.0+).

## Overview

This skill enables Claude to help you manage Upsun projects through the Upsun CLI. Upsun is a unified, multi-cloud Platform-as-a-Service built for teams that need flexibility without compromise. This skill covers:

- **130+ CLI commands** across 30 namespaces
- **Deployment workflows** for safe production deployments
- **Environment management** including branching, merging, and synchronization
- **Backup and restore** operations with safety checks
- **Resource scaling** and autoscaling configuration
- **Database operations** for PostgreSQL, MongoDB, Redis, and Valkey
- **Security and access** management for teams and users
- **Development tools** including SSH, tunnels, and logs

## Prerequisites

**Authentication Required**: You must be authenticated to Upsun before using any commands.

Check authentication status:
```bash
upsun auth:info
```

If not authenticated, log in via browser:
```bash
upsun auth:browser-login
```

Or using an API token:
```bash
upsun auth:api-token-login
```

All helper scripts in this skill include automatic authentication checking.

## Quick Start

### Most Common Operations

**List your projects:**
```bash
upsun projects
```

**List environments in a project:**
```bash
upsun environments -p PROJECT_ID
```

**Deploy changes to an environment:**
```bash
upsun push -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Create a backup before major changes:**
```bash
upsun backup:create -p PROJECT_ID -e ENVIRONMENT_NAME
```

**View environment logs:**
```bash
upsun logs -p PROJECT_ID -e ENVIRONMENT_NAME
```

## What Do You Want to Do?

### Deploy & Manage Code

**Deploy changes**: `environment:push`, `environment:deploy`, `environment:redeploy`
**Create test environment**: `environment:branch`
**Merge changes**: `environment:merge`
**Monitor deployments**: `activity:list`, `activity:log`

→ See [references/deployments.md](references/deployments.md) for deployment patterns
→ Use `examples/deploy-workflow.sh` for complete deployment workflow

### Manage Environments

**List environments**: `environment:list`
**View details**: `environment:info`, `environment:url`
**Create branch**: `environment:branch`
**Activate/deactivate**: `environment:activate`, `environment:delete`
**Pause/resume**: `environment:pause`, `environment:resume`
**Sync from parent**: `environment:synchronize`

→ See [references/environments.md](references/environments.md) for environment lifecycle

### Backup & Restore

**Create backup**: `backup:create`
**List backups**: `backup:list`
**View backup details**: `backup:get`
**Restore backup**: `backup:restore`
**Delete old backups**: `backup:delete`

→ See [references/backups.md](references/backups.md) for backup patterns

### Manage Projects & Organizations

**Create project**: `project:create`
**List projects**: `project:list`
**Get project**: `project:get` (clone locally)
**Initialize project**: `project:init`
**Manage organizations**: `organization:*`
**Manage teams**: `team:*`

→ See [references/projects-organizations.md](references/projects-organizations.md)

### Work with Databases & Services

**Database dump**: `db:dump`
**Run SQL**: `db:sql`
**MongoDB operations**: `service:mongo:dump`, `service:mongo:export`, `service:mongo:shell`
**Redis CLI**: `service:redis-cli`
**Valkey CLI**: `service:valkey-cli`
**View relationships**: `environment:relationships`

→ See [references/services-databases.md](references/services-databases.md)

### Scale Resources & Monitor Performance

**View resources**: `resources:get`
**Set resources**: `resources:set`
**Configure autoscaling**: `autoscaling:set`, `autoscaling:get`
**Monitor metrics**: `metrics:cpu`, `metrics:memory`, `metrics:disk`
**View container sizes**: `resources:size:list`

→ See [references/resources-scaling.md](references/resources-scaling.md)
→ Use `scripts/resource-audit.sh` for cross-environment analysis

### Manage Access & Security

**Add/remove users**: `user:add`, `user:delete`, `user:list`
**Manage teams**: `team:create`, `team:user:add`
**SSH keys**: `ssh-key:add`, `ssh-key:list`, `ssh-key:delete`
**SSL certificates**: `certificate:add`, `certificate:list`
**Authentication**: `auth:browser-login`, `auth:api-token-login`

→ See [references/access-security.md](references/access-security.md)

### Configure Domains, Routes & Variables

**Add domain**: `domain:add`
**List routes**: `route:list`
**Manage variables**: `variable:create`, `variable:list`, `variable:update`
**Configure integrations**: `integration:add`, `integration:list`
**View environment URLs**: `environment:url`

→ See [references/integration-variables.md](references/integration-variables.md)

### Development Tools

**SSH to environment**: `environment:ssh`
**Transfer files**: `environment:scp`
**Create tunnels**: `tunnel:open`, `tunnel:single`
**View logs**: `environment:logs`
**Run Drush commands**: `environment:drush`
**Enable Xdebug**: `environment:xdebug`

→ See [references/development-tools.md](references/development-tools.md)

## Command Discovery

### Browse by Category

Use the reference documentation to find commands organized by category:

| Use Case | Reference File |
|----------|----------------|
| Alphabetical command lookup | [COMMAND-INDEX.md](references/COMMAND-INDEX.md) |
| Environment lifecycle & operations | [environments.md](references/environments.md) |
| Deployment patterns & workflows | [deployments.md](references/deployments.md) |
| Backup & restore operations | [backups.md](references/backups.md) |
| Project & organization management | [projects-organizations.md](references/projects-organizations.md) |
| Database & service operations | [services-databases.md](references/services-databases.md) |
| Resource scaling & performance | [resources-scaling.md](references/resources-scaling.md) |
| Security & access control | [access-security.md](references/access-security.md) |
| Domains, routes, variables | [integration-variables.md](references/integration-variables.md) |
| Development tools | [development-tools.md](references/development-tools.md) |
| Common issues & solutions | [troubleshooting.md](references/troubleshooting.md) |

### Search by Command Name

If you know the command name, use [references/COMMAND-INDEX.md](references/COMMAND-INDEX.md) for quick alphabetical lookup of all 130+ commands.

## Permission Configuration

Add Upsun permissions to `.claude/settings.local.json`:

### Minimal (Read-only operations)
```json
{
  "permissions": {
    "allow": [
      "Bash(upsun auth:info:*)",
      "Bash(upsun environment:list:*)",
      "Bash(upsun environment:info:*)",
      "Bash(upsun activity:list:*)",
      "Bash(upsun project:list:*)"
    ]
  }
}
```

### Standard (Common workflows)
```json
{
  "permissions": {
    "allow": [
      "Bash(upsun auth:*)",
      "Bash(upsun environment:*)",
      "Bash(upsun activity:*)",
      "Bash(upsun backup:*)",
      "Bash(upsun deploy*:*)",
      "Bash(upsun project:*)"
    ]
  }
}
```

### Full (All operations)
```json
{
  "permissions": {
    "allow": [
      "Bash(upsun *:*)"
    ]
  }
}
```

See [references/access-security.md](references/access-security.md) for detailed permission scope information.

## Getting Help

- **List all commands**: `upsun list`
- **Command help**: `upsun COMMAND --help`
- **Online documentation**: `upsun docs`
- **Project console**: `upsun console`
- **Troubleshooting**: See [references/troubleshooting.md](references/troubleshooting.md)

## Version Compatibility

This skill is designed for Upsun CLI v5.6.0 and above. Check your version:

```bash
upsun --version
```

Update the CLI if needed following the [Upsun CLI installation guide](https://docs.upsun.com/administration/cli.html).
