## Sinatra Application Configuration

Reference configuration for Sinatra web applications on Upsun.

**Template Usage**: Customize configuration for specific Sinatra application requirements. Do not include explanatory comments in production configurations.

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

**Configuration Details**:

- **Ruby Version**: Use the exact Ruby runtime version that matches your application's gem compatibility; example above uses ruby:3.4 from the Registry.
- **Bundle Configuration**: BUNDLE_WITHOUT excludes development/test dependencies so production installs are lighter.
- **Database URL**: The build hook appends a DATABASE_URL environment export line to .environment for database-enabled apps. Upsun service bindings provide DB credentials at runtime.
- **File Management**: Basic mounts for logs and temporary files are included (tmp).
- **Port Handling**: Sinatra uses the $PORT environment variable provided by the platform.

### Database Options

**Supported Databases**: Sinatra works with PostgreSQL, MariaDB/MySQL, and SQLite through standard Ruby adapters (pg, mysql2, sqlite3).

**PostgreSQL** (recommended):
- Service type: `postgresql:16`
- URL scheme: `postgresql://`

**MariaDB/MySQL Alternative**:
- Service type: `mariadb:11.4`
- URL scheme: `mysql://`

**SQLite** (development only):
- Remove the database service and relationships
- Add a writable mount for the database file (commonly `storage` or `db`)
- URL scheme: `sqlite3://`
