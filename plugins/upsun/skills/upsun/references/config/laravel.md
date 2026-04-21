## Laravel Application Configuration

Reference configuration for Laravel PHP web applications on Upsun.

**Framework Overview**: Full-featured PHP web framework with MVC architecture, ORM, routing, and comprehensive tooling.

Example configuration

```yaml
applications:
  myapp:
    type: php:8.4

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        composer install --no-progress --no-interaction --optimize-autoloader --no-dev

        # Laravel encryption key from platform entropy
        echo >> .environment 'export APP_KEY="base64:$(echo $PLATFORM_PROJECT_ENTROPY | base32 --decode | base64)"'

        # Set the DB_URL at runtime with explicit scheme matching the database service
        # Use mysql:// for MariaDB/MySQL services, postgresql:// for PostgreSQL services
        echo >> .environment 'export DB_URL="mysql://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'

        # Set the APP_URL at runtime based on the primary route.
        echo >> .environment 'export APP_URL=$(echo $PLATFORM_ROUTES | base64 --decode | jq -r "to_entries[] | select(.value.primary == true) | .key")'

      deploy: |
        set -ex
        php artisan migrate --force
        php artisan optimize

    web:
      locations:
        /:
          root: public
          passthru: /index.php
          index: [index.php]
        /storage:
          root: storage/app/public
          scripts: false

    runtime:
      extensions:
        - pdo_mysql

    variables:
      env:
        APP_ENV: production
        APP_DEBUG: false
        DB_CONNECTION: mariadb

    relationships:
      db: {}

    mounts:
      storage/app/public: {source: storage}
      storage/app/private: {source: storage}
      storage/framework/views: {source: storage}
      storage/framework/sessions: {source: storage}
      storage/logs: {source: storage}

      storage/framework/cache: {source: tmp}
      bootstrap/cache: {source: tmp}

services:
  db:
    type: mariadb:11.4
```

Configuration Details

- PHP Version: Use the platform php:8.4 runtime to match modern Laravel releases.
- Composer: Production-optimized installation with autoloader optimization and no dev dependencies.
- APP_KEY: Generated from platform entropy for encryption security and written into the environment file during build.
- Database Configuration: DB_URL is set at build time to create a runtime-ready connection string. DB_CONNECTION is set to `mariadb` for MariaDB/MySQL.
- File Storage: Persistent mounts for uploads and logs, temporary mounts for cache directories required by Laravel.
- Artisan Commands: Automated migrations and optimization run during deployment.

Database Options

Supported Databases: Laravel supports MySQL/MariaDB, PostgreSQL, and SQLite.

MariaDB/MySQL (recommended):
- Use `pdo_mysql` extension
- DB_URL scheme: `mysql://`
- DB_CONNECTION: `mariadb`

PostgreSQL Alternative:
- Change service type to `postgresql:16`
- Use `pdo_pgsql` extension
- DB_URL scheme: `postgresql://`
- DB_CONNECTION: `pgsql`

SQLite (discouraged for production):
- Remove database service
- Use `pdo_sqlite` extension
- DB_CONNECTION: `sqlite`
- Requires writable storage mount for database file

Laravel-Specific Features

- Encryption Key: APP_KEY generated from platform entropy ensures security.
- Auto-Configuration: DB_URL and DB_CONNECTION automatically configure database connections.
- Storage Linking: Mount configuration handles `public/storage` symlink requirements.
- Automated Migrations: Database schema updates run during deployment phase.
- Performance Optimization: `php artisan optimize` caches configuration, routes, and other data.
