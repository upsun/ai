## PHP Application Configuration

### Build Configuration

Important: Always use `flavor: none` for explicit dependency management control.

The default `composer` flavor installs dependencies implicitly without production optimizations, potentially including development packages in production builds.

Recommended Configuration:
```yaml
applications:
  example:
    # If your app lives in a subdirectory, set `source.root`. Omit this block to use the repository root.
    # source:
    #   root: subdir

    type: php:8.5

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        composer install --no-progress --no-interaction --optimize-autoloader --no-dev
```

Build Command Explanation:
- `--no-dev`: Excludes development dependencies
- `--optimize-autoloader`: Optimizes class loading for production
- `--no-interaction`: Prevents interactive prompts
- `--no-progress`: Reduces output verbosity

### Extension Configuration

Default Extensions: Most common PHP extensions are pre-installed.

Additional Extensions:
```yaml
applications:
  example:
    type: php:8.5
    runtime:
      extensions:
        - sodium
        - redis
        - mongodb
```

### Web Configuration

PHP-FPM Defaults:
- Omit `web.commands.start` — PHP-FPM starts automatically
- Omit `web.upstream` settings — the defaults are correct for PHP-FPM

When you need custom static handling, define `web.locations` as usual; for typical PHP apps pass-through is used so PHP-FPM handles dynamic requests.

### Runtime Settings

PHP Configuration:
```yaml
applications:
  example:
    type: php:8.5
    variables:
      php:
        memory_limit: 256M
        max_execution_time: 300
        upload_max_filesize: 10M
```

Environment Variables:
- Never put secrets in `variables.env` — use the build hook to create a `.environment` file that reads secrets from protected Upsun variables.
- Use `PLATFORM_PROJECT_ENTROPY` for secrets when appropriate (for example, Symfony's APP_SECRET).

Common Settings:
- `memory_limit`: Increase for memory-intensive applications
- `max_execution_time`: Extend for long-running scripts
- `upload_max_filesize`: Adjust for file upload requirements

### Example: Single PHP app with one service

```yaml
applications:
  app:
    type: php:8.5

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        composer install --no-progress --no-interaction --optimize-autoloader --no-dev

    web:
      locations:
        '/':
          root: web
          passthru: /index.php
          expires: 1h

    mounts:
      web/uploads:
        source: storage

    relationships:
      database: {}

services:
  database:
    type: mariadb:11.8
```

Notes and gotchas:
- Keep build-time dependency installation explicit via the build hook to avoid unintentionally shipping dev dependencies.
- Do not add `web.commands.start` for typical PHP apps.
- If you declare a `services:` entry, ensure the consuming application lists a matching `relationships:` entry.

Version verification reminder: Always verify runtime and service versions against the canonical registry before committing: https://meta.upsun.com/images
