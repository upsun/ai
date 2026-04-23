# .upsun/config.yaml -- Reference Templates

Full config reference: https://developer.upsun.com/docs/get-started/here/configure

## Hook phases

Hooks are shell scripts (Dash) that run in order:

1. **`build`** -- runs in an isolated container with internet access but **no access to services** (databases, caches). The app filesystem is writable here. Start with `set -ex` to fail fast.
2. **`deploy`** -- runs after the app is built and connected to services, but before it accepts internet traffic. Use for database migrations, cache warming. The app filesystem is **read-only** at this point.
3. **`post_deploy`** -- runs after the app is open to traffic. Use only when tasks must happen after public access (reduces deployment downtime for long-running tasks, but risks inconsistency).

## `.environment` file

A shell script at the app root, sourced at runtime. Use it to construct derived env vars from the auto-generated service variables.

Example: build a DB_URL from the auto-generated relationship vars. If the relationship is named "db", Upsun exposes $DB_HOST, $DB_PORT, etc.

```bash
# Example: build a DB_URL from the auto-generated relationship vars.
# If the relationship is named "db", Upsun exposes $DB_HOST, $DB_PORT, etc.
export DB_URL="$DB_SCHEME://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"
```

Write to `.environment` in the build hook if the content needs shell logic.

---

## Minimal app (no services)

This is a minimal, working YAML example. Note: runtimes and services must use exact, supported versions from the canonical registry (see "Registry" below).

```yaml
applications:
  myapp:
    type: 'nodejs:24'        # supported runtime version from the registry
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

Always declare services under the top-level `services` key and connect them via `relationships` in the application. This example uses the canonical shorthand: relationship keys match service names and are empty objects.

```yaml
applications:
  myapp:
    type: 'nodejs:24'
    build:
      flavor: none
    hooks:
      build: |
        set -ex
        npm install
        npm run build
    web:
      commands:
        start: 'node server.js'
    relationships:
      db: {}      # exposes $DB_HOST, $DB_PORT, $DB_USERNAME, $DB_PASSWORD, $DB_PATH, $DB_SCHEME
      redis: {}

services:
  db:
    type: 'postgresql:16'   # supported version
  redis:
    type: 'redis:8.0'       # supported version
```

Note: relationship names become the env var prefix (uppercased). In the example above, use $DB_HOST, $REDIS_HOST, etc.

---

## Monorepo (multiple apps)

Use `source.root` to point each app at its subdirectory. Keep relationship shorthand consistent: relationship keys match service names.

```yaml
applications:
  frontend:
    source:
      root: /frontend
    type: 'nodejs:24'
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
    type: 'nodejs:24'
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
      db: {}

services:
  db:
    type: 'postgresql:16'

routes:
  'https://{default}/':
    type: upstream
    upstream: 'frontend:http'
```

---

## Composable images (when registry images are insufficient)

Use composable images when you need Nix packages or specific runtime variants not available in the Registry.

Key points:
- Use `type: composable:stable` to declare a composable image application.
- Provide `stack.runtimes` and `stack.packages` with exact Nix package names (use the `nix_package_search` tool to verify names).
- Composable images are for applications only (cannot be used for `services`).

Minimal composable example:

```yaml
applications:
  myapp:
    type: 'composable:stable'
    stack:
      runtimes:
        - python@3.13
      packages:
        - ffmpeg
    hooks:
      build: |
        set -ex
        pip install -r requirements.txt
    web:
      commands:
        start: 'gunicorn app:app'
```

---

## Registry

Canonical registry URL: https://meta.upsun.com/images

Always verify every image type and version against that registry before committing configuration. Only use versions whose status is "supported" in the registry snapshot. Do not invent or assume versions.

Examples of supported images (see registry for full list):
- nodejs:24
- php:8.5
- python:3.14
- postgresql:16
- redis:8.0

---

## Notes and best practices

- `{default}` resolves to the project's default domain. In preview environments, auto-generated URLs are used.
- Resources (CPU, memory, disk) are set via the API/CLI (`upsun resources:set`), not in the YAML config.
- `web.commands.start` is expected for all runtimes except PHP (which uses PHP-FPM by default).
- For PHP apps, set `build.flavor: none` and use `composer install --no-dev --no-interaction --optimize-autoloader` in the build hook.
- Relationship names become the env var prefix (uppercased). The vars are runtime-only and available only after the application is connected to services.
- Use `upsun init` to auto-detect your stack and generate a starter config.

---

## Per-language and per-framework details

See framework-specific configuration notes and examples:

- [config/directus.md](config/directus.md)
- [config/django.md](config/django.md)
- [config/drupal.md](config/drupal.md)
- [config/echo.md](config/echo.md)
- [config/express.md](config/express.md)
- [config/flask.md](config/flask.md)
- [config/gatsby.md](config/gatsby.md)
- [config/gin.md](config/gin.md)
- [config/go.md](config/go.md)
- [config/hugo.md](config/hugo.md)
- [config/jekyll.md](config/jekyll.md)
- [config/js.md](config/js.md)
- [config/laravel.md](config/laravel.md)
- [config/nextjs.md](config/nextjs.md)
- [config/nuxt.md](config/nuxt.md)
- [config/php.md](config/php.md)
- [config/python.md](config/python.md)
- [config/rails.md](config/rails.md)
- [config/reactjs.md](config/reactjs.md)
- [config/ruby.md](config/ruby.md)
- [config/sinatra.md](config/sinatra.md)
- [config/static.md](config/static.md)
- [config/strapi.md](config/strapi.md)
- [config/sylius.md](config/sylius.md)
- [config/symfony.md](config/symfony.md)
- [config/vite.md](config/vite.md)
- [config/vuejs.md](config/vuejs.md)
- [config/wordpress.md](config/wordpress.md)

When scanning these files, prefer the examples that match your detected framework version and verify the runtime/service versions against the canonical registry URL above.

---

## Quick checklist before committing

- Verify every `type:` value uses an exact, supported version from https://meta.upsun.com/images
- Ensure every service declared under `services:` has a matching `relationships:` entry in at least one application
- Use `build` hooks for build-time shell logic and write `.environment` there if you need derived env vars
- Prefer explicit `build.flavor: none` for Node.js and PHP and run dependency installation in `hooks.build`
- Use composable images only when Registry runtimes cannot satisfy package/runtime requirements and verify Nix package names with `nix_package_search`
