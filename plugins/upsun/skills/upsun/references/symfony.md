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
      extensions:
        - pdo_pgsql
        - apcu
        - mbstring
        - sodium

    relationships:
      database: {} 

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

If your project uses MariaDB/MySQL instead of PostgreSQL, change the database service to mariadb:11.4 and use the pdo_mysql extension instead of pdo_pgsql.

If the project specifically uses SQLite (check composer.json for ext-pdo_sqlite, existing .sqlite files, or .env DATABASE_URL), configure SQLite properly rather than changing the database type.

#### SQLite Configuration (when required by project)

If the project requires SQLite (composer.json lists ext-pdo_sqlite or .sqlite files exist):

A writable mount is needed, and the pdo_sqlite extension must be enabled. No database service is required (and therefore no relationship entry).

```yaml
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
        echo >> .environment 'export APP_SECRET="$PLATFORM_PROJECT_ENTROPY"'
        echo >> .environment 'export DATABASE_URL="sqlite:///data/database.sqlite"'

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
      data:
        source: storage
      var/cache:
        source: tmp
      var/log:
        source: storage
```

### Message consumer

When the symfony/messenger Composer package is installed, add a worker that consumes messages:

```yaml
workers:
  messenger:
    commands:
      start: symfony console --time-limit=3600 --memory-limit=64M messenger:consume async
```
