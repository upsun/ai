# .upsun/config.yaml -- Reference Templates

Full config reference: https://developer.upsun.com/docs/get-started/here/configure

## Hook phases

Hooks are shell scripts (Dash) that run in order:

1. **`build`** -- runs in an isolated container with internet access but **no access to services** (databases, caches). The app filesystem is writable here. Start with `set -ex` to fail fast.
2. **`deploy`** -- runs after the app is built and connected to services, but before it accepts internet traffic. Use for database migrations, cache warming. The app filesystem is **read-only** at this point.
3. **`post_deploy`** -- runs after the app is open to traffic. Use only when tasks must happen after public access (reduces deployment downtime for long-running tasks, but risks inconsistency).

## `.environment` file

A shell script at the app root, sourced at runtime. Use it to construct derived env vars from the auto-generated service variables:

```bash
# Example: build a DATABASE_URL from the auto-generated relationship vars.
# If the relationship is named "database", Upsun exposes $DATABASE_HOST, $DATABASE_PORT, etc.
export DATABASE_URL="${DATABASE_SCHEME}://${DATABASE_USERNAME}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_PATH}"
```

Write to `.environment` in the build hook if the content needs shell logic.

---

## Minimal app (no services)

```yaml
applications:
  myapp:
    type: 'nodejs:24'        # check https://meta.upsun.com/images for supported versions
    build:
      flavor: none           # manage dependencies explicitly in the build hook
    hooks:
      build: |
        set -ex
        npm install
        npm run build
    web:
      commands:
        start: 'node server.js'   # required for all runtimes except PHP

routes:
  'https://{default}/':
    type: upstream
    upstream: 'myapp:http'
  'https://www.{default}/':
    type: redirect
    to: 'https://{default}/'
```

---

## Adding services

To add services, declare them under the top-level `services` key and connect them via `relationships` in the app. The relationship name determines the env var prefix (uppercased, runtime-only).

```yaml
applications:
  myapp:
    # ... (type, build, hooks, web as above)
    relationships:
      database: 'db:postgresql'   # exposes $DATABASE_HOST, $DATABASE_PORT, etc.
      cache: 'redis:redis'        # exposes $CACHE_HOST, $CACHE_PORT, etc.

services:
  db:
    type: 'postgresql:16'
  redis:
    type: 'redis:7.2'
```

---

## Monorepo (multiple apps)

Use `source.root` to point each app at its subdirectory:

```yaml
applications:
  frontend:
    source:
      root: /frontend
    type: 'nodejs:22'
    build:
      flavor: none
    hooks:
      build: |
        set -ex
        npm install
        npm run build
    web:
      commands:
        start: 'npm start'

  backend:
    source:
      root: /backend
    type: 'nodejs:22'
    build:
      flavor: none
    hooks:
      build: |
        set -ex
        npm install
    web:
      commands:
        start: 'npm start'
    relationships:
      database: 'db:postgresql'

services:
  db:
    type: 'postgresql:16'

routes:
  'https://{default}/':
    type: upstream
    upstream: 'frontend:http'
```

---

## Available runtimes, services and versions

Canonical source (always up to date): https://meta.upsun.com/images

Each image entry has a `versions` map with a `status` of `supported`, `deprecated`, `retired`, or `decommissioned`.
Use only `supported` (or `deprecated` if a specific older version is required).
Services have `"service": true`; runtimes have `"service": false`.

---

## Notes

- `{default}` resolves to the project's default domain. In preview environments, auto-generated URLs are used.
- Resources (CPU, memory, disk) are set via the API/CLI (`upsun resources:set`), not in the YAML config.
- `web.commands.start` is expected for all runtimes except PHP (which uses PHP-FPM by default).
- For PHP apps, set `build.flavor: none` and use `composer install --no-dev --no-interaction --optimize-autoloader` in the build hook.
- Relationship names become the env var prefix (uppercased). The vars are runtime-only.
- Run `upsun init` to auto-detect your stack and generate a starter config.

---

## Framework and language templates

For per-language and per-framework starter configs (Node.js, PHP, Python, Go, Ruby,
Next.js, Django, WordPress, etc.) see the templates in `config/`.
The index at [references/config/generated-index.md](config/generated-index.md) lists
every available file. Load the relevant file when the user's stack is known.
