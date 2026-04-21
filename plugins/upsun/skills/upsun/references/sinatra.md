## Sinatra Application Configuration

Reference configuration for Sinatra web applications on Upsun.

Template Usage: Customize configuration for specific Sinatra application requirements. Do not include explanatory comments in production configurations.

```yaml
applications:
  app:
    type: ruby:3.4

    hooks:
      build: |
        set -ex
        # Install Node.js dependencies if package.json exists
        if [ -f "package.json" ]; then
          npm install
        fi

        bundle install

        # Database URL configuration for database-enabled applications
        echo >> .environment 'export DATABASE_URL="$DB_SCHEME://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'

    web:
      commands:
        start: bundle exec ruby app.rb

      locations:
        /:
          root: public
          passthru: true

    variables:
      env:
        RACK_ENV: production
        BUNDLE_WITHOUT: development:test

    mounts:
      log:
        source: tmp
      tmp:
        source: tmp

    relationships:
      db: {}

services:
  db:
    type: postgresql:16
```

## Configuration Details

- Ruby Version: Use the exact Ruby runtime matching application requirements (example uses ruby:3.4).
- Bundle Configuration: BUNDLE_WITHOUT excludes development/test dependencies.
- Database URL: Automatic database configuration via the DATABASE_URL environment variable for database-enabled apps.
- File Management: Basic mounts for logs and temporary files.
- Port Handling: Sinatra will bind to the $PORT environment variable provided by Upsun.

### Database Options

Supported Databases: Sinatra works with PostgreSQL, MariaDB/MySQL, and SQLite through database adapters.

PostgreSQL (recommended):
- Service type: `postgresql:16`
- URL scheme: `postgresql://`

MariaDB/MySQL Alternative:
- Service type: `mariadb:11.4`
- URL scheme: `mysql://`

SQLite (development only):
- Remove the database service and relationship.
- Add a writable mount for the database file (typically `storage`).
- URL scheme: `sqlite3://`
