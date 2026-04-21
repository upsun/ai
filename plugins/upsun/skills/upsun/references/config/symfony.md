# Symfony guidance

## Symfony Application Configuration

Reference configuration for Symfony PHP web applications on Upsun.

**Framework Priority**: This Symfony-specific configuration takes precedence over general PHP guidance when conflicts arise.

**Template Usage**: Adapt configuration to project requirements. Do not include explanatory comments in production configurations.

```yaml
applications:
  site:
    # If your app source is in a subdirectory, add a source block like:
    # source:
    #   root: path/to/subdir

    type: php:8.4

    build:
      flavor: none

    hooks:
      # Run the official Symfony "configurator" script, which makes symfony-build and symfony-deploy available.
      # Using this configurator is highly encouraged on Upsun.
      build: |
        set -ex
        curl -sfS https://get.symfony.com/cloud/configurator | bash
        symfony-build # Using this means there is no need for 'composer install'

      deploy: |
        set -ex
        symfony-deploy

    web:
      locations:
        /:
          root: public
          passthru: /index.php
          expires: 5m

    runtime:
      # Enable non-default PHP extensions.
      extensions:
        # Use `pdo_pgsql` for PostgreSQL or `pdo_mysql` for MariaDB/MySQL.
        - pdo_pgsql

        # Enhancements (optional, but harmless).
        - apcu
        - mbstring
        - sodium

    relationships:
      database: {} # Expose the database service to the app: Symfony will auto-discover if named "database".

    mounts:
      var/cache:
        source: tmp
      var/log:
        source: storage

    variables:
      php:
        opcache.preload: config/preload.php

services:
  database:
    type: postgresql:16
```

### Database choice

Preferred approach: Symfony works best with managed database services (PostgreSQL or MariaDB/MySQL) for production deployments, as they offer better performance, reliability, and maintainability.

However, respect project requirements: If the project specifically uses SQLite (check `composer.json` for `ext-pdo_sqlite`, existing `.sqlite` files, or `.env` DATABASE_URL), then configure SQLite properly rather than changing the database type.

To modify the application to use MariaDB instead of PostgreSQL, change the type of the related database service to MariaDB (for example `mariadb:11.4` instead of `postgresql:16`) and change the app's extensions to use `pdo_mysql` (instead of `pdo_pgsql`).

#### SQLite Configuration (when required by project)

If the project requires SQLite (composer.json lists `ext-pdo_sqlite` or `.sqlite` files exist):

A `mount` is needed, as well as the correct `pdo_sqlite` extension. No database service is needed (and therefore no relationship).

The mount stores the SQLite file (commonly at `data`) so it is writable. Symfony must be able to write to its database at runtime.

```yaml
# SQLite example (only if necessary; not recommended). This replaces the service-based DB above.
applications:
  site:
    type: php:8.4

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        curl -sfS https://get.symfony.com/cloud/configurator | bash
        symfony-build

        # Set runtime secrets and SQLite database path
        echo >> .environment "export APP_SECRET=\"$PLATFORM_PROJECT_ENTROPY\""
        echo >> .environment "export DATABASE_URL=\"sqlite:///data/database.sqlite\""

    web:
      locations:
        /:
          root: public
          passthru: /index.php
          expires: 5m

    runtime:
      extensions:
        - pdo_sqlite
        - apcu
        - mbstring
        - sodium

    mounts:
      data: # Writable storage for the SQLite database file.
        source: storage
      var/cache:
        source: tmp
      var/log:
        source: storage
```

### Message consumer

When the `symfony/messenger` Composer package is installed, add a worker in the `workers` section that consumes messages:

```yaml
workers:
  messenger:
    commands:
      # Consume "async" messages (as configured in the routing section of config/packages/messenger.yaml)
      start: symfony console --time-limit=3600 --memory-limit=64M messenger:consume async
```
