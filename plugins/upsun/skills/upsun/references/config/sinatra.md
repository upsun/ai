## Sinatra Application Configuration

Reference configuration for Sinatra web applications on Upsun.

**Template Usage**: Customize configuration for specific Sinatra application requirements. Do not include explanatory comments in production configurations.

```yaml
applications:
  app:
    type: ruby:4.0

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
    type: postgresql:18
```

**Configuration Details**:

- **Ruby Version**: Use the exact image version from the Registry that matches application requirements (example above uses ruby:4.0).
- **Bundle Configuration**: BUNDLE_WITHOUT excludes development/test dependencies.
- **Database URL**: Automatic database configuration via environment variable for database-enabled apps (written to .environment during build).
- **File Management**: Basic mounts for logs and temporary files.
- **Port Handling**: Sinatra automatically uses the $PORT environment variable.

### Database Options

**Supported Databases**: Sinatra works with PostgreSQL, MariaDB/MySQL, and SQLite through database adapters.

PostgreSQL (recommended):
- Service type: `postgresql:18`
- URL scheme: `postgresql://`

MariaDB/MySQL Alternative:
- Service type: `mariadb:11.8`
- URL scheme: `mysql://`

SQLite (development only):
- Remove the database service and relationship from the config.
- Add a writable mount for the database file (typically `storage`).
- URL scheme: `sqlite3://`

---

Note: Always verify runtime and service versions against the canonical registry before committing. Canonical registry URL: https://meta.upsun.com/images
