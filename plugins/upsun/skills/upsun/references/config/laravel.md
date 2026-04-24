## Laravel Application Configuration

Reference configuration for Laravel PHP web applications on Upsun.

**Framework Overview**: Full-featured PHP web framework with MVC architecture, ORM, routing, and comprehensive tooling.

**Template Usage**: Customize configuration for specific Laravel version and project requirements. Exclude explanatory comments from production configurations.

```yaml
applications:
  myapp:
    

    type: php:8.5

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
      # Persistent storage
      storage/app/public: {source: storage}
      storage/app/private: {source: storage}
      storage/framework/views: {source: storage}
      storage/framework/sessions: {source: storage}
      storage/logs: {source: storage}

      # Temporary caches
      storage/framework/cache: {source: tmp}
      bootstrap/cache: {source: tmp}

services:
  db:
    type: mariadb:11.8
```

**Configuration Details**:

- **PHP Version**: Use exact version from Registry matching Laravel requirements
- **Composer**: Production-optimized installation with autoloader optimization
- **APP_KEY**: Generated from platform entropy for encryption security
- **Database Configuration**: Automatic Laravel database connection via environment variables
- **File Storage**: Persistent mounts for uploads and logs, temporary mounts for caches
- **Artisan Commands**: Automated migrations and optimization during deployment

### Database Options

**Supported Databases**: Laravel supports MySQL/MariaDB, PostgreSQL, and SQLite

**MariaDB/MySQL** (recommended):
- Use `pdo_mysql` extension
- DB_URL scheme: `mysql://`
- DB_CONNECTION: `mariadb`

**PostgreSQL Alternative**:
- Change service type to `postgresql:18`
- Use `pdo_pgsql` extension  
- DB_URL scheme: `postgresql://`
- DB_CONNECTION: `pgsql`

**SQLite** (discouraged for production):
- Remove database service
- Use `pdo_sqlite` extension
- DB_CONNECTION: `sqlite`
- Requires writable storage mount for database file

### Laravel-Specific Features

- **Encryption Key**: APP_KEY generated from platform entropy ensures security
- **Auto-Configuration**: DB_URL and DB_CONNECTION automatically configure database connections
- **Storage Linking**: Mount configuration handles `public/storage` symlink requirements
- **Automated Migrations**: Database schema updates run during deployment phase
- **Performance Optimization**: Artisan optimize commands cache configuration and routes

---

Version numbers change over time. Verify against https://meta.upsun.com/images before committing configuration.
