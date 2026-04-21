## WordPress Application Configuration

WordPress is a PHP content management system and website building framework.

**Configuration Variants**:
- **WordPress Bedrock**: Git and Composer-managed WordPress boilerplate
- **Standard WordPress**: Traditional WordPress installation

**Bedrock Detection**: Look for `roots/bedrock-autoloader` in composer.json dependencies

**Template Usage**: Adapt PHP version, database type, and directory structure based on WordPress variant and project requirements.

```yaml
applications:
  app:
    type: php:8.4

    dependencies:
      php:
        wp-cli/wp-cli-bundle: '^2'

    hooks:
      build: |
        set -ex
        composer install --no-progress --no-interaction --optimize-autoloader --no-dev

        # Set up environment variables for use at runtime.
        echo >> .environment 'export DATABASE_URL="${DB_SCHEME}://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_PATH}"'
        echo >> .environment 'export WP_HOME=$(echo $PLATFORM_ROUTES | base64 --decode | jq -r "to_entries[] | select(.value.primary == true) | .key")'
        echo >> .environment 'export WP_SITEURL="${WP_HOME%/}/wp"'

      deploy: |
        set -ex
        if wp core is-installed; then
          wp cache flush
          wp core update-db
        else
          echo "Skipping: WordPress site not yet installed."
        fi

    web:
      locations:
        /:
          root: web
          passthru: /wp/index.php
          index:
            - index.php
          expires: 600
          scripts: true
          allow: true
          rules:
            ^/composer\.json:
              allow: false
            ^/license\.txt$:
              allow: false
            ^/readme\.html$:
              allow: false
        /wp/wp-content/cache:
          root: web/wp/wp-content/cache
          scripts: false
          allow: false
        /wp/wp-content/uploads:
          root: web/app/uploads
          scripts: false
          allow: false
          rules:
            '(?<!\-lock)\.(?i:jpe?g|gif|png|svg|bmp|ico|css|js(?:on)?|eot|ttf|woff|woff2|pdf|docx?|xlsx?|pp[st]x?|psd|odt|key|mp[2-5g]|m4[av]|og[gv]|wav|mov|wm[av]|avi|3g[p2])$':
              allow: true
              expires: 1w

    mounts:
      web/app/wp-content/cache:
        source: tmp
      web/app/uploads:
        source: storage

    crons:
      wp-cron:
        spec: '*/10 * * * *'
        commands:
          start: |
            if wp core is-installed; then
              wp cron event run --due-now
            else
              echo Skipping: WordPress site not yet installed.
            fi
        shutdown_timeout: 600

    relationships:
      db: {}

    file_modifications:
      - wp/wp-config.php
      - .env

services:
  db:
    type: mariadb:11.4

routes:
  https://{default}/:
    type: upstream
    upstream: app:http
    cache:
      enabled: true
      cookies:
        - '/^wordpress_*/'
        - '/^wp-*/'
```

**Configuration Details**:

- **WordPress CLI**: wp-cli-bundle required for deployment hooks and cron jobs
- **Environment Variables**: DATABASE_URL, WP_HOME, and WP_SITEURL configured automatically
- **File Uploads**: Persistent storage mount for user uploads
- **Cache Management**: Temporary mount for WordPress cache with periodic flushing
- **Security**: Blocks access to sensitive files (composer.json, license.txt, readme.html)
- **Cron Jobs**: wp-cron runs every 10 minutes for scheduled tasks
- **Route Caching**: Enabled with cookie-based cache invalidation

### WordPress without Bedrock

**Standard WordPress Configuration Adjustments**:

- **Document Root**: Change from `web/` to `public/` or `wordpress/`
- **Uploads Directory**: Move to `wp-content/uploads/` under document root
- **URL Paths**: Direct `/wp-content/` paths without `/wp/` prefix
- **Composer**: May not be present - remove composer installation if no composer.json
- **File Structure**: Adjust mount paths and location roots for traditional WordPress layout
