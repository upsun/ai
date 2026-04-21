# Symfony guidance

## Symfony Application Configuration

Reference configuration for Symfony PHP web applications on Upsun.

**Framework Priority**: This Symfony-specific configuration takes precedence over general PHP guidance when conflicts arise.

**Template Usage**: Adapt configuration to project requirements. Do not include explanatory comments in production configurations.

```yaml
applications:
  site:
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

**Preferred approach:** Symfony works best with managed database services (PostgreSQL or MariaDB/MySQL) for production deployments, as they offer better performance, reliability, and maintainability.

If the project specifically uses SQLite (check `composer.json` for `ext-pdo_sqlite`, existing `.sqlite` files, or `.env` DATABASE_URL), configure SQLite properly rather than changing the database type.

To use MariaDB instead of PostgreSQL, change the database service type to `mariadb:11.4` and use the `pdo_mysql` extension (replace `pdo_pgsql` with `pdo_mysql`).

#### SQLite Configuration (when required by project)

If the project requires SQLite (composer.json lists `ext-pdo_sqlite` or `.sqlite` files exist), a mount is needed and the `pdo_sqlite` extension must be enabled. No external database service or relationship is required.

This minimal example shows the application fragment adjusted for SQLite storage:

```yaml
applications:
  site:
    type: php:8.4

    hooks:
      build: |
        set -ex
        curl -sfS https://get.symfony.com/cloud/configurator | bash
        symfony-build

        # Set runtime secrets and SQLite database path
        echo >> .environment 'export APP_SECRET="$PLATFORM_PROJECT_ENTROPY"'
        echo >> .environment 'export DATABASE_URL="sqlite:///data/database.sqlite"'

    mounts:
      data: # Writable storage for the SQLite database file.
        source: storage
      var/cache:
        source: tmp
      var/log:
        source: storage

    runtime:
      extensions:
        - pdo_sqlite
        - apcu
        - mbstring
        - sodium
```

### Message consumer

When the `symfony/messenger` Composer package is installed, add a worker that consumes messages:

```yaml
workers:
  messenger:
    commands:
      # Consume "async" messages (as configured in config/packages/messenger.yaml)
      start: symfony console --time-limit=3600 --memory-limit=64M messenger:consume async
```
