---
name: upsun-domain
description: Use when the user asks to "configure domain", "manage variables", "configure integrations", "add domain", "list routes", "create environment variable", "Upsun CLI commands" for configuration, or "manage routes". Manages domains, routes, environment variables, and SCM integrations via the Upsun CLI.
version: 1.0.0
---

# Upsun Domain, Variables & Integrations Skill

Manage custom domains, routes, environment variables, and external integrations on Upsun.

## Prerequisites

```bash
upsun auth:info
```

## Key Commands

### Domains

```bash
upsun domain:list -p PROJECT_ID                              # List all domains
upsun domain:add DOMAIN -p PROJECT_ID                        # Add custom domain (auto-SSL)
upsun domain:add DOMAIN -p PROJECT_ID \
  --cert cert.crt --key key.key                              # Add with custom SSL cert
upsun domain:get DOMAIN -p PROJECT_ID                        # Domain & certificate details
upsun domain:update DOMAIN -p PROJECT_ID                     # Update SSL cert
upsun domain:delete DOMAIN -p PROJECT_ID                     # Remove domain
```

### Routes

```bash
upsun route:list -p PROJECT_ID -e ENV                        # List all routes
upsun route:get "https://example.com/" -p PROJECT_ID -e ENV  # Route details
```

### Environment Variables

```bash
upsun variable:list -p PROJECT_ID -e ENV                     # List variables
upsun variable:get NAME -p PROJECT_ID -e ENV                 # Get variable details
upsun variable:get NAME -p PROJECT_ID -e ENV --property value  # Show actual value
upsun variable:create -p PROJECT_ID -e ENV \
  --name API_KEY --value "sk_live_xxx" \
  --visible-runtime true --sensitive true                    # Create secret variable
upsun variable:update NAME -p PROJECT_ID -e ENV --value NEW  # Update variable
upsun variable:delete NAME -p PROJECT_ID -e ENV              # Remove variable
```

> After changing variables, a redeploy is required:
> ```bash
> upsun redeploy -p PROJECT_ID -e ENV
> ```

### Integrations

```bash
upsun integration:list -p PROJECT_ID                         # List integrations
upsun integration:get INTEGRATION_ID -p PROJECT_ID           # Integration details
upsun integration:add -p PROJECT_ID --type github \
  --repository org/repo --build-pull-requests true           # Add GitHub integration
upsun integration:add -p PROJECT_ID --type webhook \
  --url https://hooks.slack.com/xxx                          # Add webhook
upsun integration:validate INTEGRATION_ID -p PROJECT_ID      # Test connection
upsun integration:update INTEGRATION_ID -p PROJECT_ID        # Modify settings
upsun integration:delete INTEGRATION_ID -p PROJECT_ID        # Remove integration
upsun integration:activity:list -p PROJECT_ID                # Integration event log
```

## Variable Visibility Options

```bash
# Runtime-only secret (most common for API keys)
upsun variable:create -p PROJECT_ID -e production \
  --name STRIPE_SECRET_KEY --value "sk_live_xxx" \
  --visible-runtime true --sensitive true

# Available at both build and runtime (e.g. NODE_ENV)
upsun variable:create -p PROJECT_ID -e production \
  --name NODE_ENV --value "production" \
  --visible-build true --visible-runtime true

# Build-only (e.g. compiler flags)
upsun variable:create -p PROJECT_ID -e production \
  --name BUILD_FLAGS --value "--optimize" \
  --visible-build true

# Project-wide variable (inherited by all environments)
upsun variable:create -p PROJECT_ID \
  --level project --name GLOBAL_CONFIG --value "shared"
```

## Domain Setup Checklist

```bash
# 1. Add apex and www domains
upsun domain:add example.com -p PROJECT_ID
upsun domain:add www.example.com -p PROJECT_ID

# 2. Configure DNS as instructed by the command output
#    example.com     A     <IP_ADDRESS>
#    www.example.com CNAME <PROJECT>.upsun.app.

# 3. Verify domain and auto-provisioned SSL (can take 5–15 min)
upsun domain:get example.com -p PROJECT_ID
```

## Variable Naming Conventions

```
DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD   # Database
API_STRIPE_KEY, API_SENDGRID_KEY                  # External APIs
FEATURE_NEW_CHECKOUT, FEATURE_BETA_UI             # Feature flags
APP_ENV, APP_DEBUG, LOG_LEVEL                     # App config
```

## Reference

See [reference.md](reference.md) for:
- Full route configuration YAML examples
- Source operations (`source-operation:list`, `source-operation:run`)
- Variable precedence rules (env > project > defaults)
- CI/CD GitHub integration workflow
- Webhook notification setup (Slack, etc.)
- Production and staging variable templates
