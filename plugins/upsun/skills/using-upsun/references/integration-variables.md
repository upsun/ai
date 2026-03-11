# Configuration: Domains, Routes, Variables, and Integrations

Complete guide to managing domains, routes, environment variables, and integrations on Upsun.

## Overview

Upsun provides flexible configuration through multiple mechanisms:
- **Domains** - Custom domain names
- **Routes** - URL routing and behavior
- **Variables** - Environment-specific configuration
- **Integrations** - External service connections

## Domain Management

### List Domains

View all domains in a project:

```bash
upsun domain:list -p PROJECT_ID
```

**Alias:** `domains`

**Example:**
```bash
upsun domains -p abc123
```

**Example output:**
```
+-------------------------+-------------+------------+
| Domain                  | SSL         | Status     |
+-------------------------+-------------+------------+
| example.com             | Let's Encrypt| Active    |
| www.example.com         | Let's Encrypt| Active    |
| staging.example.com     | Let's Encrypt| Active    |
+-------------------------+-------------+------------+
```

### Add Domain

Add a custom domain to your project:

```bash
upsun domain:add DOMAIN -p PROJECT_ID
```

**Example:**
```bash
upsun domain:add example.com -p abc123
```

**With SSL certificate:**
```bash
upsun domain:add example.com -p abc123 --cert /path/to/cert.crt --key /path/to/key.key
```

**What happens:**
1. Domain added to project
2. Let's Encrypt certificate auto-provisioned (if no custom cert)
3. DNS instructions provided
4. Route configuration updated

**DNS Configuration Required:**

After adding domain, configure DNS:

```
# For apex domain (example.com)
example.com.     A     <IP_ADDRESS>

# For www subdomain
www.example.com. CNAME <PROJECT>.upsun.app.

# Alternative: Use ALIAS/ANAME for apex
example.com.     ALIAS <PROJECT>.upsun.app.
```

### View Domain Details

Get information about a specific domain:

```bash
upsun domain:get DOMAIN -p PROJECT_ID
```

**Example:**
```bash
upsun domain:get example.com -p abc123
```

**Details include:**
- Domain name
- SSL certificate status
- Replacement certificate (if any)
- Creation date
- Expiration date

### Update Domain

Modify domain configuration:

```bash
upsun domain:update DOMAIN -p PROJECT_ID
```

**Example - Update SSL certificate:**
```bash
upsun domain:update example.com -p abc123 \
  --cert /path/to/new-cert.crt \
  --key /path/to/new-key.key
```

### Delete Domain

Remove a domain from project:

```bash
upsun domain:delete DOMAIN -p PROJECT_ID
```

**Example:**
```bash
upsun domain:delete old-domain.com -p abc123
```

**⚠️ Warning:** Domain will no longer route to your application.

## Route Management

### List Routes

View all routes for an environment:

```bash
upsun route:list -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Alias:** `routes`

**Example:**
```bash
upsun routes -p abc123 -e production
```

**Example output:**
```
+-----------------------------+----------+-------------+
| URL                         | Type     | To          |
+-----------------------------+----------+-------------+
| https://example.com/        | upstream | app:http    |
| https://www.example.com/    | redirect | example.com |
| https://api.example.com/    | upstream | api:http    |
+-----------------------------+----------+-------------+
```

### View Route Details

Get detailed information about a specific route:

```bash
upsun route:get ROUTE_ID -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example:**
```bash
upsun route:get "https://example.com/" -p abc123 -e production
```

**Route information includes:**
- URL pattern
- Type (upstream, redirect)
- Target application/service
- Cache configuration
- SSI settings
- HSTS settings

### Route Configuration

Routes are typically configured in `.upsun/config.yaml`:

```yaml
routes:
  "https://example.com/":
    type: upstream
    upstream: "app:http"
    cache:
      enabled: true
      default_ttl: 3600
      cookies: ['SESSION*']

  "https://www.example.com/":
    type: redirect
    to: "https://example.com/"

  "https://api.example.com/":
    type: upstream
    upstream: "api:http"
    cache:
      enabled: false
```

**Route types:**
- `upstream` - Forward to application/service
- `redirect` - Redirect to another URL

**Route options:**
- `cache` - HTTP caching configuration
- `ssi` - Server Side Includes
- `redirects` - Custom redirect rules

## Environment Variables

### List Variables

View all variables in an environment:

```bash
upsun variable:list -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Aliases:** `variables`, `var`

**Example:**
```bash
upsun var -p abc123 -e production
```

**Output:**
```
+------------------+----------+--------+---------+
| Name             | Level    | Value  | Visible |
+------------------+----------+--------+---------+
| DATABASE_URL     | env      | ***    | runtime |
| API_KEY          | env      | ***    | runtime |
| DEBUG_MODE       | project  | false  | both    |
+------------------+----------+--------+---------+
```

### View Variable

Get details of a specific variable:

```bash
upsun variable:get NAME -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Alias:** `vget`

**Example:**
```bash
upsun vget DATABASE_URL -p abc123 -e production
```

**Show actual value:**
```bash
upsun vget API_KEY -p abc123 -e production --property value
```

### Create Variable

Add a new environment variable:

```bash
upsun variable:create -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Interactive mode:**
```bash
upsun variable:create -p abc123 -e production
# Prompts for name, value, visibility
```

**Command-line mode:**
```bash
upsun variable:create \
  -p abc123 -e production \
  --name API_KEY \
  --value "sk_live_abc123" \
  --visible-runtime true \
  --sensitive true
```

**Variable options:**

- `--name` - Variable name
- `--value` - Variable value
- `--json` - Value is JSON (parse as object)
- `--sensitive` - Hide value in UI/CLI
- `--visible-build` - Available during build
- `--visible-runtime` - Available at runtime
- `--prefix env:` - Environment-level variable

**Visibility combinations:**

```bash
# Runtime only (most common)
upsun variable:create -p abc123 -e production \
  --name DATABASE_PASSWORD \
  --value "secret" \
  --visible-runtime true \
  --sensitive true

# Build and runtime
upsun variable:create -p abc123 -e production \
  --name NODE_ENV \
  --value "production" \
  --visible-build true \
  --visible-runtime true

# Build only
upsun variable:create -p abc123 -e production \
  --name BUILD_FLAGS \
  --value "--optimize" \
  --visible-build true
```

### Update Variable

Modify an existing variable:

```bash
upsun variable:update NAME -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example:**
```bash
upsun variable:update API_KEY -p abc123 -e production --value "new_key_value"
```

**Update visibility:**
```bash
upsun variable:update DEBUG_MODE -p abc123 -e staging \
  --visible-runtime true \
  --visible-build false
```

**⚠️ Note:** Changing variables requires application redeploy to take effect.

**Update workflow:**
```bash
# 1. Update variable
upsun variable:update DATABASE_URL -p abc123 -e production --value "new_connection_string"

# 2. Redeploy to apply
upsun redeploy -p abc123 -e production

# 3. Verify new value is active
upsun ssh -p abc123 -e production -- 'echo $DATABASE_URL'
```

### Delete Variable

Remove a variable:

```bash
upsun variable:delete NAME -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example:**
```bash
upsun variable:delete OLD_API_KEY -p abc123 -e production
```

### Project-Level Variables

Create variables inherited by all environments:

```bash
upsun variable:create -p abc123 \
  --level project \
  --name GLOBAL_CONFIG \
  --value "shared_value"
```

**Precedence:**
1. Environment-level variables (highest)
2. Project-level variables
3. Default values (lowest)

**Override project variable in environment:**
```bash
# Project level
upsun variable:create -p abc123 --level project --name API_URL --value "https://api.example.com"

# Override in staging
upsun variable:create -p abc123 -e staging --name API_URL --value "https://staging-api.example.com"
```

## Integrations

### List Integrations

View all integrations for a project:

```bash
upsun integration:list -p PROJECT_ID
```

**Alias:** `integrations`

**Example:**
```bash
upsun integrations -p abc123
```

### View Integration

Get details of a specific integration:

```bash
upsun integration:get INTEGRATION_ID -p PROJECT_ID
```

**Example:**
```bash
upsun integration:get abc123def -p abc123
```

### Add Integration

Create a new integration:

```bash
upsun integration:add -p PROJECT_ID
```

**Integration types:**
- `github` - GitHub repository
- `gitlab` - GitLab repository
- `bitbucket` - Bitbucket repository
- `webhook` - Generic webhook

**GitHub integration example:**
```bash
upsun integration:add \
  -p abc123 \
  --type github \
  --repository user/repo \
  --build-pull-requests true \
  --fetch-branches true
```

**Webhook integration example:**
```bash
upsun integration:add \
  -p abc123 \
  --type webhook \
  --url https://example.com/webhook
```

**Integration options:**
- `--build-pull-requests` - Auto-build PRs
- `--fetch-branches` - Sync all branches
- `--prune-branches` - Delete merged branches
- `--build-draft-pull-requests` - Build draft PRs

### Update Integration

Modify integration settings:

```bash
upsun integration:update INTEGRATION_ID -p PROJECT_ID
```

**Example:**
```bash
upsun integration:update abc123def -p abc123 \
  --build-pull-requests false
```

### Delete Integration

Remove an integration:

```bash
upsun integration:delete INTEGRATION_ID -p PROJECT_ID
```

**Example:**
```bash
upsun integration:delete abc123def -p abc123
```

### Validate Integration

Test integration configuration:

```bash
upsun integration:validate INTEGRATION_ID -p PROJECT_ID
```

**Example:**
```bash
upsun integration:validate abc123def -p abc123
```

**Checks:**
- Connection to external service
- Authentication credentials
- Webhook endpoint accessibility
- Configuration validity

### Integration Activities

View integration activity logs:

```bash
upsun integration:activity:list -p PROJECT_ID
```

**Alias:** `integration:activities`

**Example:**
```bash
upsun integration:activities -p abc123
```

**View specific activity:**
```bash
upsun integration:activity:get ACTIVITY_ID -p abc123
```

**View activity log:**
```bash
upsun integration:activity:log ACTIVITY_ID -p abc123
```

## Source Operations

### List Source Operations

View available source operations:

```bash
upsun source-operation:list -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Alias:** `source-ops`

**Example:**
```bash
upsun source-ops -p abc123 -e production
```

**Common source operations:**
- `update` - Update dependencies
- `upgrade` - Upgrade framework versions
- `sync` - Sync with upstream

### Run Source Operation

Execute a source operation:

```bash
upsun source-operation:run OPERATION -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Example:**
```bash
upsun source-operation:run update -p abc123 -e staging
```

**Use cases:**
- Automated dependency updates
- Framework upgrades
- Template synchronization
- Custom automation workflows

## Configuration Best Practices

### Variable Management

**Naming conventions:**
- Use UPPERCASE for environment variables
- Prefix by category: `DB_`, `API_`, `CACHE_`
- Be descriptive: `STRIPE_SECRET_KEY` not `KEY1`

**Security:**
- Mark sensitive variables as `--sensitive true`
- Never commit secrets to Git
- Rotate secrets regularly
- Use different values per environment

**Organization:**
```bash
# Database
DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD

# External APIs
API_STRIPE_KEY, API_SENDGRID_KEY, API_SLACK_WEBHOOK

# Feature flags
FEATURE_NEW_CHECKOUT, FEATURE_BETA_UI

# Environment-specific
APP_ENV, APP_DEBUG, LOG_LEVEL
```

### Domain Configuration

**Best practices:**
- Use HTTPS for all domains
- Redirect www to non-www (or vice versa)
- Configure HSTS for security
- Monitor certificate expiration

**Standard setup:**
```bash
# Add apex domain
upsun domain:add example.com -p abc123

# Add www subdomain
upsun domain:add www.example.com -p abc123

# Configure routes in .upsun/config.yaml
# - example.com -> app (primary)
# - www.example.com -> redirect to example.com
```

### Integration Workflows

**CI/CD integration:**
```bash
# 1. Add GitHub integration
upsun integration:add -p abc123 \
  --type github \
  --repository myorg/myrepo \
  --build-pull-requests true \
  --fetch-branches true \
  --prune-branches true

# 2. Configure branch mappings
# - main -> production
# - staging -> staging
# - feature/* -> preview environments
```

**Webhook notifications:**
```bash
# Deploy notifications to Slack
upsun integration:add -p abc123 \
  --type webhook \
  --url https://hooks.slack.com/services/XXX \
  --events environment.push,environment.deploy
```

## Configuration Templates

### Production Variables Template

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"

# Database
upsun variable:create -p $PROJECT -e $ENV \
  --name DB_HOST --value "database.internal" \
  --visible-runtime true

# App Configuration
upsun variable:create -p $PROJECT -e $ENV \
  --name APP_ENV --value "production" \
  --visible-build true --visible-runtime true

upsun variable:create -p $PROJECT -e $ENV \
  --name APP_DEBUG --value "false" \
  --visible-runtime true

# API Keys (sensitive)
upsun variable:create -p $PROJECT -e $ENV \
  --name STRIPE_SECRET_KEY --value "sk_live_xxx" \
  --visible-runtime true --sensitive true

upsun variable:create -p $PROJECT -e $ENV \
  --name SENDGRID_API_KEY --value "SG.xxx" \
  --visible-runtime true --sensitive true
```

### Staging Variables Template

```bash
#!/bin/bash
PROJECT="abc123"
ENV="staging"

# Use test API keys in staging
upsun variable:create -p $PROJECT -e $ENV \
  --name STRIPE_SECRET_KEY --value "sk_test_xxx" \
  --visible-runtime true --sensitive true

# Enable debug mode
upsun variable:create -p $PROJECT -e $ENV \
  --name APP_DEBUG --value "true" \
  --visible-runtime true

# Different log level
upsun variable:create -p $PROJECT -e $ENV \
  --name LOG_LEVEL --value "debug" \
  --visible-runtime true
```

## Related Commands

**Environments:**
- `environment:info` - Environment properties
- See [environments.md](environments.md)

**Deployments:**
- `environment:redeploy` - Apply variable changes
- See [deployments.md](deployments.md)

**Security:**
- `certificate:add` - SSL certificates
- See [access-security.md](access-security.md)

## Troubleshooting

**Domain not resolving:**
- Check DNS configuration
- Verify domain added: `domain:list`
- Check route configuration
- Wait for DNS propagation (up to 48 hours)

**Variable not available:**
- Check visibility settings
- Verify environment scope
- Redeploy application
- Check for typos in variable name

**Integration not working:**
- Validate configuration: `integration:validate`
- Check activity logs
- Verify webhook URL accessible
- Review authentication credentials

**SSL certificate issues:**
- Check domain ownership
- Verify DNS points to Upsun
- Wait for Let's Encrypt provisioning
- Check certificate expiration

For more troubleshooting, see [troubleshooting.md](troubleshooting.md).
