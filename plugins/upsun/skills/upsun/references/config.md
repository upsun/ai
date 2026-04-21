# .upsun/config.yaml -- Reference Templates

Full config reference: https://developer.upsun.com/docs/get-started/here/configure

## Hook phases

Hooks are Dash shell scripts that run in order:

1. **`build`** -- runs in an isolated container with internet access but **no access to services** (databases, caches). The app filesystem is writable here. Start hooks with `set -ex` to fail fast on errors.
2. **`deploy`** -- runs after the app is built and connected to services, but before it accepts internet traffic. Use for database migrations, cache warming. The app filesystem is **read-only** at this point.
3. **`post_deploy`** -- runs after the app is open to traffic. Use only when tasks must happen after public access (reduces deployment downtime for long-running tasks, but risks inconsistency).

## `.environment` file

A shell script at the app root, sourced at runtime. Use it to construct derived env vars from the auto-generated relationship variables:

```bash
# Example: build a DATABASE_URL from auto-generated relationship vars.
# If the relationship is named "database", Upsun exposes $DATABASE_HOST, $DATABASE_PORT, etc.
export DATABASE_URL="${DATABASE_SCHEME}://${DATABASE_USERNAME}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_PATH}"
```

Write to `.environment` in the build hook if the content needs shell logic.

---

## Minimal app (no services)

A minimal working config for a single Node.js app. Adjust the runtime version to a supported image from the registry.

```yaml
applications:
  myapp:
    type: 'nodejs:24'        # pick a supported runtime version from the registry
    build:
      flavor: none           # prefer explicit dependency management in build hook
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

Relationship names become the env var prefix (uppercased). The vars are runtime-only.

---

## Monorepo (multiple apps)

Point each app at its subdirectory using `source.root` so multiple apps can coexist in one repository.

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

## Composable images (Nix-based)

Use composable images when the standard registry runtimes do not provide required packages. A composable application declares `type: composable:stable` and a `stack` of runtimes and extra Nix packages.

Minimal composable example:

```yaml
applications:
  myapp:
    type: composable:stable
    stack:
      runtimes:
        - python@3.13
      packages:
        - ffmpeg
        - python313Packages.yq
    hooks:
      build: |
        set -ex
        pip install -r requirements.txt
    web:
      commands:
        start: gunicorn app:app
```

Notes:
- Always verify Nix package names with the package search tool before adding them.
- Composable images are for applications only (not services) and cannot be mixed with Registry runtimes in the same application.

---

## Available runtimes, services and versions

Canonical source (always up to date): https://meta.upsun.com/images

Each image entry has a `versions` map with a `status` of `supported`, `deprecated`, `retired`, or `decommissioned`. Use only `supported` (or `deprecated` if a specific older version is required).

---

## Routes

The top-level `routes` section defines public HTTP endpoints. A default route mapping 'https://{default}/' is commonly used when there is a single application.

---

## Notes

- `{default}` resolves to the project's default domain. In preview environments, auto-generated URLs are used.
- Resources (CPU, memory, disk) are set via the API/CLI (`upsun resources:set`), not in the YAML config.
- `web.commands.start` is expected for all runtimes except PHP (which uses PHP-FPM by default).
- For PHP apps, set `build.flavor: none` and use `composer install --no-dev --no-interaction --optimize-autoloader` in the build hook.
- Relationship names become the env var prefix (uppercased). The vars are runtime-only.
- Run `upsun init` to auto-detect your stack and generate a starter config.

---

Per-language and per-framework details

For framework- and language-specific configuration patterns and examples, see the companion reference files below. Each link is a relative path to a file with focused guidance and minimal examples:

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

Use the per-framework pages for concrete build hooks, common relationships, recommended routes, and any runtime-specific caveats.
