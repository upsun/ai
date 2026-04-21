## Drupal Application Configuration

Reference configuration for Drupal applications on Upsun.

**Framework Overview**: Content management system with modular architecture, extensible through contributed modules and themes.

**Template Usage**: Customize configuration for specific Drupal version and project requirements. Exclude explanatory comments from production configurations.

```yaml
applications:
  drupal:
    type: php:8.4

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        # Download dependencies.
        composer install --no-progress --no-interaction --optimize-autoloader --no-dev

        # Create a .environment file to configure the environment.
        echo >> .environment '# Add Composer tools (such as drush) to the PATH.'
        echo >> .environment 'export PATH="$PATH:$PLATFORM_APP_DIR/vendor/bin"'

        # Set the URI for Drush commands. (Note the quoting here has been carefully checked and tested: use it verbatim).
        echo >> .environment 'export PRIMARY_URL=$(echo "$PLATFORM_ROUTES" | base64 --decode | jq -r "to_entries[] | select(.value.primary) | .key")'
        echo >> .environment 'export DRUSH_OPTIONS_URI=${PRIMARY_URL%/}'

        # Create settings files.
        if [ ! -f web/sites/default/settings.php ]; then
          cp web/sites/default/default.settings.php web/sites/default/settings.php
        fi
        if ! grep -q -F settings.upsun.php web/sites/default/settings.php; then
          echo >> web/sites/default/settings.php "// Upsun configuration"
          echo >> web/sites/default/settings.php "if (getenv('PLATFORM_APPLICATION') && file_exists(__DIR__ . '/settings.upsun.php')) {"
          echo >> web/sites/default/settings.php "  require_once __DIR__ . '/settings.upsun.php';"
          echo >> web/sites/default/settings.php "}"
        fi

        if [ ! -f web/sites/default/settings.upsun.php ]; then
          curl -sfSL https://raw.githubusercontent.com/upsun/config-assets/main/drupal/11/settings.upsun.php > web/sites/default/settings.upsun.php
        fi

      deploy: |
        set -ex
        cd web
        if [ -n "$(drush status --field=bootstrap)" ]; then
          drush -y cache-rebuild
          drush -y updatedb
          if [ -n "$(ls config/sync/*.yml 2>/dev/null)" ]; then
            drush -y config-import
          else
            echo "No config to import. Skipping."
          fi
        else
          echo "Drupal not installed. Skipping standard Drupal deploy steps"
        fi

    web:
      locations:
        /:
          root: web
          expires: 5m
          passthru: /index.php
          allow: false
          rules:
            '\.(avif|webp|jpe?g|png|gif|svgz?|css|js|map|ico|bmp|eot|woff2?|otf|ttf)$':
              allow: true
            '^/robots\.txt$':
              allow: true
            '^/sitemap\.xml$':
              allow: true
            '^/sites/sites\.php$':
              scripts: false
            '^/sites/[^/]+/settings.*?\.php$':
              scripts: false
        /sites/default/files:
          allow: true
          expires: 5m
          passthru: /index.php
          root: web/sites/default/files
          scripts: false
          rules:
            '^/sites/default/files/(css|js)':
              expires: 2w

    mounts:
      web/sites/default/files:
        source: storage
      tmp:
        source: storage
      private:
        source: storage
      .drush:
        source: storage
      drush-backups:
        source: storage

    relationships:
      db: {}
      cache: {}

    crons:
      # Run Drupal's cron tasks every 19 minutes.
      drupal:
        spec: '*/19 * * * *'
        commands:
          start: 'cd web ; drush core-cron'

    runtime:
      extensions:
        - redis
        - sodium
        - apcu
        - blackfire
        - gd

services:
  db:
    type: mariadb:11.4
  cache:
    type: redis-persistent:7.4

routes:
  https://{default}/:
    type: upstream
    upstream: drupal:http
    cache:
      enabled: true
      # Allow only Drupal session cookies in the HTTP cache key.
      cookies: ['/^SS?ESS/', '/^Drupal.visitor/']
  https://www.{default}/:
    type: redirect
    to: https://{default}/
```

**Configuration Details**:

- **PHP Version**: Use PHP 8.4 for Drupal 11, or 8.3+ for Drupal 10
- **Web Root**: Drupal core files in `web/` subdirectory
- **Settings Files**: Automated setup of Upsun-specific configuration
- **Drush Integration**: PATH configuration and URI setup for command-line operations via `.environment`
- **File Handling**: Comprehensive mount strategy for files, caches, and backups
- **Caching**: Route-level caching with Drupal-specific cookie handling

### Database Options

**MariaDB** (recommended):
- Production-ready with excellent Drupal compatibility
- Use latest stable version in the Registry (11.4)
- No additional PHP extensions required

**PostgreSQL** (advanced):
- Change service type to `postgresql:16`
- Add `pdo_pgsql` PHP extension via `runtime.extensions`
- Requires PostgreSQL-specific Drupal configuration

### Redis Caching

Redis is frequently used in Drupal sites. Its use in a project can be detected based on the `drupal/redis` dependency in `composer.json`, or potentially based on other context.

To remove Redis support, remove the `cache` service and relationship and the `redis` PHP extension.

The `settings.upsun.php` automatically configures Redis (if the relationship is named `cache` and if the module is used), but it is compatible with non-Redis sites too.

### Drupal Version Considerations

The `settings.upsun.php` (as shown in the build hook above) is compatible with Drupal versions 8, 9, 10 and 11, and likely later versions too.
