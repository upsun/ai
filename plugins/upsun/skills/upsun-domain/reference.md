# Configuration: Domains, Routes, Variables, and Integrations — Reference

Complete guide to managing domains, routes, environment variables, and integrations on Upsun.

## Domain Management

### List Domains

```bash
upsun domain:list -p PROJECT_ID
# Alias: domains

upsun domains -p abc123
```

Example output:
```
+-------------------------+---------------+--------+
| Domain                  | SSL           | Status |
+-------------------------+---------------+--------+
| example.com             | Let's Encrypt | Active |
| www.example.com         | Let's Encrypt | Active |
+-------------------------+---------------+--------+
```

### Add Domain

```bash
upsun domain:add DOMAIN -p PROJECT_ID

# With custom SSL certificate:
upsun domain:add example.com -p abc123 --cert /path/to/cert.crt --key /path/to/key.key
```

What happens: domain added → Let's Encrypt certificate auto-provisioned → DNS instructions provided → route config updated.

**DNS Configuration:**
```
# Apex domain
example.com.     A     <IP_ADDRESS>

# www subdomain
www.example.com. CNAME <PROJECT>.upsun.app.

# Alternative: ALIAS/ANAME for apex
example.com.     ALIAS <PROJECT>.upsun.app.
```

### View Domain Details

```bash
upsun domain:get DOMAIN -p PROJECT_ID
```

Details: domain name, SSL certificate status, creation/expiration dates.

### Update Domain

```bash
upsun domain:update DOMAIN -p PROJECT_ID

# Update SSL certificate:
upsun domain:update example.com -p abc123 \
  --cert /path/to/new-cert.crt \
  --key /path/to/new-key.key
```

### Delete Domain

```bash
upsun domain:delete DOMAIN -p PROJECT_ID
```

## Route Management

### List Routes

```bash
upsun route:list -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: routes

upsun routes -p abc123 -e production
```

Example output:
```
+-----------------------------+----------+-------------+
| URL                         | Type     | To          |
+-----------------------------+----------+-------------+
| https://example.com/        | upstream | app:http    |
| https://www.example.com/    | redirect | example.com |
+-----------------------------+----------+-------------+
```

### View Route Details

```bash
upsun route:get "https://example.com/" -p PROJECT_ID -e ENVIRONMENT_NAME
```

### Route Configuration in `.upsun/config.yaml`

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

Route types: `upstream` (forward to app/service), `redirect` (redirect to another URL).

## Environment Variables

### List Variables

```bash
upsun variable:list -p PROJECT_ID -e ENVIRONMENT_NAME
# Aliases: variables, var

upsun var -p abc123 -e production
```

### View Variable

```bash
upsun variable:get NAME -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: vget

upsun vget DATABASE_URL -p abc123 -e production
upsun vget API_KEY -p abc123 -e production --property value   # show actual value
```

### Create Variable

```bash
# Interactive:
upsun variable:create -p abc123 -e production

# Command-line:
upsun variable:create \
  -p abc123 -e production \
  --name API_KEY \
  --value "sk_live_abc123" \
  --visible-runtime true \
  --sensitive true
```

**Options:**
- `--name` - Variable name
- `--value` - Variable value
- `--json` - Parse value as JSON
- `--sensitive` - Hide value in UI/CLI
- `--visible-build` - Available during build phase
- `--visible-runtime` - Available at runtime
- `--prefix env:` - Environment-level variable

**Visibility combinations:**
```bash
# Runtime only (most common for secrets)
upsun variable:create -p abc123 -e production \
  --name DATABASE_PASSWORD --value "secret" \
  --visible-runtime true --sensitive true

# Build and runtime
upsun variable:create -p abc123 -e production \
  --name NODE_ENV --value "production" \
  --visible-build true --visible-runtime true

# Build only
upsun variable:create -p abc123 -e production \
  --name BUILD_FLAGS --value "--optimize" \
  --visible-build true
```

### Update Variable

```bash
upsun variable:update NAME -p PROJECT_ID -e ENVIRONMENT_NAME

upsun variable:update API_KEY -p abc123 -e production --value "new_key_value"

upsun variable:update DEBUG_MODE -p abc123 -e staging \
  --visible-runtime true --visible-build false
```

> Changing variables requires redeploy:
> ```bash
> upsun variable:update DATABASE_URL -p abc123 -e production --value "new_string"
> upsun redeploy -p abc123 -e production
> upsun ssh -p abc123 -e production -- 'echo $DATABASE_URL'
> ```

### Delete Variable

```bash
upsun variable:delete NAME -p PROJECT_ID -e ENVIRONMENT_NAME
```

### Project-Level Variables

```bash
# Create project-wide variable (inherited by all environments)
upsun variable:create -p abc123 \
  --level project \
  --name GLOBAL_CONFIG \
  --value "shared_value"

# Override in a specific environment
upsun variable:create -p abc123 --level project --name API_URL --value "https://api.example.com"
upsun variable:create -p abc123 -e staging --name API_URL --value "https://staging-api.example.com"
```

**Precedence:** environment-level > project-level > defaults.

## Integrations

### List Integrations

```bash
upsun integration:list -p PROJECT_ID
# Alias: integrations
```

### View Integration

```bash
upsun integration:get INTEGRATION_ID -p PROJECT_ID
```

### Add Integration

```bash
upsun integration:add -p PROJECT_ID
```

**Integration types:** `github`, `gitlab`, `bitbucket`, `webhook`

**GitHub integration:**
```bash
upsun integration:add \
  -p abc123 \
  --type github \
  --repository user/repo \
  --build-pull-requests true \
  --fetch-branches true
```

**Webhook integration:**
```bash
upsun integration:add \
  -p abc123 \
  --type webhook \
  --url https://example.com/webhook
```

**Options:**
- `--build-pull-requests` - Auto-build PRs
- `--fetch-branches` - Sync all branches
- `--prune-branches` - Delete merged branches
- `--build-draft-pull-requests` - Build draft PRs

### Update Integration

```bash
upsun integration:update INTEGRATION_ID -p PROJECT_ID \
  --build-pull-requests false
```

### Delete Integration

```bash
upsun integration:delete INTEGRATION_ID -p PROJECT_ID
```

### Validate Integration

```bash
upsun integration:validate INTEGRATION_ID -p PROJECT_ID
```

Checks: connection to external service, authentication credentials, webhook endpoint accessibility.

### Integration Activity Logs

```bash
upsun integration:activity:list -p PROJECT_ID
# Alias: integration:activities

upsun integration:activity:get ACTIVITY_ID -p abc123
upsun integration:activity:log ACTIVITY_ID -p abc123
```

## Source Operations

### List Source Operations

```bash
upsun source-operation:list -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: source-ops
```

Common operations: `update` (update dependencies), `upgrade` (upgrade framework versions), `sync` (sync with upstream).

### Run Source Operation

```bash
upsun source-operation:run OPERATION -p PROJECT_ID -e ENVIRONMENT_NAME

upsun source-operation:run update -p abc123 -e staging
```

## Configuration Templates

### Production Variables

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"

upsun variable:create -p $PROJECT -e $ENV \
  --name APP_ENV --value "production" \
  --visible-build true --visible-runtime true

upsun variable:create -p $PROJECT -e $ENV \
  --name APP_DEBUG --value "false" \
  --visible-runtime true

upsun variable:create -p $PROJECT -e $ENV \
  --name STRIPE_SECRET_KEY --value "sk_live_xxx" \
  --visible-runtime true --sensitive true

upsun variable:create -p $PROJECT -e $ENV \
  --name SENDGRID_API_KEY --value "SG.xxx" \
  --visible-runtime true --sensitive true
```

### Staging Variables (Override)

```bash
#!/bin/bash
PROJECT="abc123"
ENV="staging"

upsun variable:create -p $PROJECT -e $ENV \
  --name STRIPE_SECRET_KEY --value "sk_test_xxx" \
  --visible-runtime true --sensitive true

upsun variable:create -p $PROJECT -e $ENV \
  --name APP_DEBUG --value "true" \
  --visible-runtime true

upsun variable:create -p $PROJECT -e $ENV \
  --name LOG_LEVEL --value "debug" \
  --visible-runtime true
```

## Troubleshooting

**Domain not resolving:**
- Check DNS configuration
- Verify domain added: `domain:list`
- Check route configuration
- Wait for DNS propagation (up to 48 hours)

**Variable not available:**
- Check visibility settings (`--visible-build` vs `--visible-runtime`)
- Verify environment scope (project vs env level)
- Redeploy application after changes
- Check for typos in variable name

**Integration not working:**
- Validate: `integration:validate INTEGRATION_ID`
- Check activity logs: `integration:activity:list`
- Verify webhook URL is publicly accessible
- Review authentication credentials

**SSL certificate issues:**
- Check domain ownership
- Verify DNS points to Upsun IP
- Wait for Let's Encrypt provisioning (5–15 minutes)
- Check certificate expiration: `domain:get DOMAIN`
