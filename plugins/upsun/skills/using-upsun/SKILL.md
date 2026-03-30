---
name: using-upsun
description: This skill provides Upsun platform-specific syntax, constraints, and configuration that differ from general knowledge. It corrects common errors in resource management, variable configuration, worker behavior, service type strings, and .upsun/config.yaml structure. This skill should be used when configuring .upsun/config.yaml, managing resources with the Upsun CLI, writing hooks/workers/crons, setting variables, deploying to Upsun, or working with Upsun services and environments. Triggers on mentions of Upsun, .upsun/config.yaml, upsun CLI commands, Platform.sh migration, or Upsun project administration.
---

# Upsun platform rules

Corrections to common errors when working with Upsun. Each section addresses a specific area where models produce incorrect syntax, fabricated config properties, or wrong CLI flags.

## Critical: resources are CLI-only

Resources (CPU, memory, disk) are managed exclusively through the CLI. They do NOT go in `.upsun/config.yaml`.

**These config properties do not exist and must never be generated:**
- `cpu:`, `resources:`, `base_memory:`, `memory_ratio:`, `size:` under apps or services
- `disk:` under services (disk is allocated via `upsun resources:set --disk`)
- T-shirt sizes (`S`, `M`, `L`, `XL`, `2XL`) anywhere in config or CLI

CPU is a **numeric value** (0.1 to 8.0+). RAM is automatically determined by the container profile.

```bash
# Set CPU for an app
upsun resources:set --size myapp:2 -p PROJECT_ID

# Set CPU for a service
upsun resources:set --size dbservice:1

# Wildcard: set all to minimum
upsun resources:set --size '*:0.1'

# Set instance count for horizontal scaling
upsun resources:set --count myapp:3

# Allocate disk to a service (value in MB, not in config)
upsun resources:set --disk dbservice:2048

# View current allocations
upsun resources:get
```

The `--size` flag syntax is `--size NAME:CPU_VALUE`. Not `--app NAME --cpu VALUE`. Not `--size NAME=VALUE`.

### Container profiles

Profiles control CPU-to-memory ratios. Set via `container_profile` in app config.

| Profile | Description |
|---|---|
| `HIGH_CPU` | More CPU relative to memory |
| `BALANCED` | Equal CPU and memory ratio (default) |
| `HIGH_MEMORY` | More memory relative to CPU |
| `HIGHER_MEMORY` | Maximum memory relative to CPU |

Do NOT invent profile names like "STANDARD" or "COMPUTE_OPTIMIZED".

### Resources-init strategies

Control initial resource allocation when creating environments:

```bash
upsun push --resources-init=minimum     # 0.1 CPU, 64MB RAM for apps, 448MB for databases
upsun environment:branch --resources-init=parent   # clone parent's resources
upsun push --resources-init=manual      # set resources after creation
upsun push --resources-init=default     # platform decides
```

## Critical: variable env: prefix

To expose a variable as a standard environment variable (e.g., `process.env.STRIPE_KEY` in Node.js), the name MUST start with `env:`. Without this prefix, the value is only accessible through the `PLATFORM_VARIABLES` base64-encoded blob.

```bash
# CORRECT: accessible as $STRIPE_SECRET_KEY in your app
upsun variable:create \
  --name env:STRIPE_SECRET_KEY \
  --value sk_live_xxx \
  --sensitive true \
  --inheritable false \
  --visible-build false \
  --visible-runtime true \
  -e main

# WRONG: NOT accessible as $STRIPE_SECRET_KEY
upsun variable:create --name STRIPE_SECRET_KEY ...
```

Variable flags:
- `--name env:VAR_NAME`: REQUIRED prefix to expose as environment variable
- `--sensitive true`: hides value in API/CLI output (cannot be read back)
- `--inheritable false`: prevents child environments from inheriting
- `--visible-build true/false`: controls availability during build phase
- `--visible-runtime true/false`: controls availability at runtime
- `--level project`: applies to all environments; `--level environment`: environment-specific
- `-e main`: targets production. Upsun's default production branch is `main`, not `production`

Build-only variable example:
```bash
upsun variable:create \
  --name env:BUILD_LICENSE \
  --value xxx \
  --sensitive true \
  --visible-build true \
  --visible-runtime false \
  --level project
```

CI/CD non-interactive mode: set `UPSUN_CLI_NO_INTERACTION=1` or use `--yes`.

## Workers

Workers are background processes defined under `workers:` in the app config.

```yaml
workers:
  queue:
    commands:
      start: 'node worker.js'
```

Worker constraints (commonly omitted, leading to incorrect advice):
- Workers do NOT run `deploy` or `post_deploy` hooks
- Workers do NOT run crons
- Workers inherit relationships and mounts from the parent app
- Workers receive **SIGTERM** on shutdown, then **SIGKILL after 15 seconds**. Applications must handle SIGTERM for graceful shutdown.
- SSH into a worker: `upsun ssh --worker queue -e main`
- Restart a stuck worker via SSH: `sv stop app && sv start app`
- Worker resources are set separately: `upsun resources:set --size 'myapp--queue:0.5'`

Do NOT add `size:`, `disk:`, or `resources:` properties under workers in config. Use CLI.

## Crons

```yaml
crons:
  cleanup:
    spec: '*/5 * * * *'
    commands:
      start: 'php artisan schedule:run'
    shutdown_timeout: 30   # seconds before SIGKILL (default: 10)
```

Constraints:
- **Minimum interval is 5 minutes**. `* * * * *` is silently clamped.
- `H` hash syntax randomizes timing to prevent contention: `H * * * *`
- Only **one cron per app container** at a time.
- Preview environments **pause crons after 14 days** without deployment.
- Run crons only on production:
  ```bash
  if [ "$PLATFORM_ENVIRONMENT_TYPE" = production ]; then
    php artisan schedule:run
  fi
  ```

## Relationship environment variables

Upsun exposes service connection details as direct environment variables (NOT the legacy `PLATFORM_RELATIONSHIPS` base64 blob).

For a PostgreSQL relationship: `POSTGRESQL_HOST`, `POSTGRESQL_PORT`, `POSTGRESQL_USERNAME`, `POSTGRESQL_PASSWORD`, `POSTGRESQL_PATH`, `POSTGRESQL_SCHEME`

View all: `upsun relationships` or `upsun ssh -- env | grep POSTGRESQL`

Do NOT use `PLATFORM_RELATIONSHIPS` with base64 decoding. Use the direct environment variables.

## Reference

For service type strings, application type strings, PHP config, mounts, composable images, source operations, and web locations config, see [references/config-reference.md](references/config-reference.md).
