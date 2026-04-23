# .upsun/config.yaml -- Reference Templates

Full config reference: https://developer.upsun.com/docs/get-started/here/configure

## Hook phases

Hooks are Dash shell scripts that run in order:

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

A smallest working web app configuration. Uses only supported runtime images from the registry snapshot.

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

Declare services under the top-level `services` key and connect them via `relationships` in the app. Use only service and runtime versions that are marked "supported" in the registry.

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
      database: {}
      cache: {}

services:
  database:
    type: 'postgresql:16'
  cache:
    type: 'redis:8.0'
```

Notes:
- Relationship names become the environment variable prefix (uppercased). In the example above the database relationship exposes $DATABASE_HOST, $DATABASE_PORT, etc.
- Every `services:` entry in the YAML must be matched by a `relationships:` entry in at least one application.

---

## Monorepo (multiple apps)

Use `source.root` to point each app at its subdirectory. Prefer the same runtime versions across apps when applicable.

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
      database: {}

services:
  database:
    type: 'postgresql:16'

routes:
  'https://{default}/':
    type: upstream
    upstream: 'frontend:http'
```

---

## Registry and allowed versions (canonical source)

Canonical image registry: https://meta.upsun.com/images

- Always verify the exact image name and version against the canonical registry before committing configuration.
- Use only versions that the registry marks as "supported". Do not use deprecated or retired versions in new configs.
- Prefer the most recent supported version for a runtime or service unless project constraints require a specific older supported version.

Supported examples from the registry snapshot (use these exact strings in `type:`):
- Runtimes: `nodejs:24`, `python:3.14`, `python:3.13`, `php:8.5`, `php:8.4`, `golang:1.26`, `ruby:4.0`
- Services: `postgresql:18`, `postgresql:17`, `postgresql:16`, `mysql:11.8`, `redis:8.0`, `rabbitmq:4.2`, `elasticsearch:7.10`

Always confirm the full, up-to-date list at the canonical registry URL above before finalizing any config changes.

---

## Quick tips

- Use `set -ex` in hooks to fail fast and emit useful logs.
- For PHP apps, omit `web.commands.start` (PHP-FPM is used by default) and set `build.flavor: none` with `composer install` in the build hook.
- Write derived environment logic into `.environment` during build rather than using complex substitution in the YAML `variables:` section.
- For composable images, use `type: composable:stable` and verify Nix package names via the `nix_package_search` tool (see composable image docs in per-framework references where applicable).

---

## Per-language and per-framework details

See framework-specific guidance and minimal examples (click to open):

- [Directus](config/directus.md)
- [Django](config/django.md)
- [Drupal](config/drupal.md)
- [Echo (Go)](config/echo.md)
- [Express](config/express.md)
- [Flask](config/flask.md)
- [Gatsby](config/gatsby.md)
- [Gin (Go)](config/gin.md)
- [Go (general)](config/go.md)
- [Hugo](config/hugo.md)
- [Jekyll](config/jekyll.md)
- [JS (generic)](config/js.md)
- [Laravel](config/laravel.md)
- [Next.js](config/nextjs.md)
- [Nuxt](config/nuxt.md)
- [PHP (general)](config/php.md)
- [Python (general)](config/python.md)
- [Rails](config/rails.md)
- [React.js](config/reactjs.md)
- [Ruby (general)](config/ruby.md)
- [Sinatra](config/sinatra.md)
- [Static sites](config/static.md)
- [Strapi](config/strapi.md)
- [Sylius](config/sylius.md)
- [Symfony](config/symfony.md)
- [Vite](config/vite.md)
- [Vue.js](config/vuejs.md)
- [WordPress](config/wordpress.md)

Each of these files contains minimal, framework-tailored examples and guidance. Follow the registry rules above when choosing runtime and service versions.

---

## Notes

- `{default}` resolves to the project's default domain. In preview environments, auto-generated URLs are used.
- Resources (CPU, memory, disk) are set via the API/CLI (`upsun resources:set`), not in the YAML config.
- `web.commands.start` is required for all runtimes except PHP (which uses PHP-FPM by default).
- Relationship names become the env var prefix (uppercased). The vars are runtime-only.
- Run `upsun init` to auto-detect your stack and generate a starter config.
