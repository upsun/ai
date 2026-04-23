# Sylius guidance

## Sylius Application Configuration

Reference configuration for Sylius eCommerce applications on Upsun.

**Framework Overview**: Sylius is a decoupled eCommerce framework built on Symfony, providing robust product management, order processing, and multi-channel sales capabilities.

**Framework Priority**: This Sylius-specific configuration takes precedence over general Symfony and PHP guidance when conflicts arise.

**Template Usage**: Adapt configuration to project requirements. Do not include explanatory comments in production configurations.

```yaml
applications:
  sylius:
    type: php:8.5

    dependencies:
      nodejs:
        n: "*"
        yarn: "*" # If yarn is used, and it probably is, then the tool dependency must be installed here.

    build:
      flavor: none

    hooks:
      build: |
        set -ex

        # Install PHP dependencies
        composer install --no-progress --no-interaction --optimize-autoloader --no-dev

        # Install and use Node.js version from .nvmrc or package.json
        n auto
        hash -r

        # Install Symfony CLI
        curl -sS https://get.symfony.com/cli/installer | bash
        mv "$PLATFORM_APP_DIR/.symfony5/bin/symfony" "$PLATFORM_APP_DIR/.global/bin/symfony"
        cat >> "$PLATFORM_APP_DIR/.global/environment" <<EOS
            export $(symfony var:export)
        EOS

        # Build frontend assets
        yarn install --frozen-lockfile
        yarn build:prod

      deploy: |
        set -ex
        rm -rf var/cache/*
        mkdir -p public/media/image
        bin/console doctrine:database:create --if-not-exists
        bin/console doctrine:migrations:migrate -n
        SYLIUS_FIXTURES_HOSTNAME=$SYMFONY_PROJECT_DEFAULT_ROUTE_HOST bin/console sylius:fixtures:load -n
        bin/console lexik:jwt:generate-keypair --skip-if-exists
        bin/console assets:install --symlink --relative public
        bin/console cache:clear

    web:
      locations:
        /:
          root: public
          passthru: /index.php
          expires: -1
        /assets/shop:
          expires: 2w
          passthru: true
          allow: false
          rules:
            '\.(css|js|jpe?g|png|gif|svgz?|ico|bmp|tiff?|wbmp|ico|jng|bmp|html|pdf|otf|woff2|woff|eot|ttf|jar|swf|ogx|avi|wmv|asf|asx|mng|flv|webm|mov|ogv|mpe|mpe?g|mp4|3gpp|weba|ra|m4a|mp3|mp2|mpe?ga|midi?)$':
              allow: true
        /media/image:
          expires: 2w
          passthru: true
          allow: false
          rules:
            '\.(jpe?g|png|gif|svgz?)$':
              allow: true
        /media/cache/resolve:
          passthru: /index.php
          expires: -1
          allow: true
          scripts: true
        /media/cache:
          expires: 2w
          passthru: true
          allow: false
          rules:
            '\.(jpe?g|png|gif|svgz?|webp)$':
              allow: true

    variables:
      env:
        APP_ENV: prod
        APP_DEBUG: '0'
        N_PREFIX: /app/.global

    runtime:
      extensions:
        - exif
        - gd
        - intl
        - pdo_mysql
        - sodium

    mounts:
      # The cache and log mounts currently have the source 'instance', to improve performance.
      var/cache:
        source: instance
      var/log:
        source: instance
      # The other mounts need to have the source 'storage' (meaning network storage).
      config/jwt:
        source: storage
      var/sessions:
        source: storage
      public/assets:
        source: storage
      public/bundles:
        source: storage
      public/uploads:
        source: storage
      public/media:
        source: storage

    crons:
      sylius-cancel-unpaid-orders:
        spec: "0 2 * * *"
        cmd: "php bin/console --env=prod sylius:cancel-unpaid-orders"
      sylius-remove-expired-carts:
        spec: "0 2 * * *"
        cmd: "php bin/console --env=prod sylius:remove-expired-carts"

    relationships:
      database: {}

services:
  database:
    type: mariadb:11.8
```

### Configuration Details

**PHP Version**: Sylius requires PHP 8.1 or higher. Use the latest stable PHP version from the registry (this reference uses php:8.5).

**Node.js Dependencies**: Sylius uses Yarn and Node.js for frontend asset compilation. The `n` tool manages Node.js versions.

**Symfony CLI**: The Symfony CLI is used for environment variable export and other Symfony-specific operations.

**Frontend Build**: Sylius requires building frontend assets during the build phase using Yarn.

**JWT Authentication**: Sylius API requires JWT keypairs, generated during deployment if not present.

**Fixtures**: Sample data can be loaded using `sylius:fixtures:load`. Remove this command in production environments.

### Database Configuration

**Database Type**: Sylius works with both MySQL/MariaDB and PostgreSQL.

**MySQL/MariaDB** (default):
- Use `pdo_mysql` extension
- Service type: `mariadb:11.8` or `mysql:11.8`

**PostgreSQL Alternative**:
- Change service type to `postgresql:18`
- Change runtime extension from `pdo_mysql` to `pdo_pgsql`

### Cron Jobs

Sylius requires scheduled tasks for maintenance:

- **Cancel Unpaid Orders**: Runs daily at 2 AM to cancel orders that remain unpaid
- **Remove Expired Carts**: Runs daily at 2 AM to clean up abandoned shopping carts

Adjust the schedule specifications as needed for your project requirements.

### Web Locations

Sylius requires multiple web location configurations:

- **Root (`/`)**: Main application entry point through `index.php`
- **Assets (`/assets/shop`)**: Compiled frontend assets with long cache expiration
- **Media (`/media/image`)**: Uploaded product images with cache headers
- **Media Cache (`/media/cache`)**: Dynamically resized images with cache headers
- **Media Cache Resolve (`/media/cache/resolve`)**: Dynamic image resizing endpoint

### Storage Mounts

Sylius requires persistent and temporary storage:

**Persistent Storage** (source: storage):
- `config/jwt`: JWT keypairs for API authentication
- `var/log`: Application logs
- `var/sessions`: User session data
- `public/assets`: Compiled and installed assets
- `public/bundles`: Symfony bundle assets
- `public/uploads`: User-uploaded files
- `public/media`: Product images and media

**Cache Storage** (source: storage):
- `var/cache`: Symfony cache files (could use tmp source for ephemeral cache)

### PHP Extensions

Required PHP extensions for Sylius:
- `exif`: Image metadata reading
- `gd`: Image manipulation
- `intl`: Internationalization support
- `pdo_mysql` or `pdo_pgsql`: Database connectivity
- `sodium`: Cryptographic operations


Note: Verify runtime and service versions against the canonical registry before committing: https://meta.upsun.com/images
