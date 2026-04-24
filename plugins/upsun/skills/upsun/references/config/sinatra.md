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
    type: postgresql:18
```

**Configuration Details**:

- **Ruby Version**: Use exact version from Registry matching application requirements
- **Bundle Configuration**: BUNDLE_WITHOUT excludes development/test dependencies
- **Database URL**: Automatic database configuration via environment variable for database-enabled apps
- **File Management**: Basic mounts for logs and temporary files
- **Port Handling**: Sinatra automatically uses $PORT environment variable

### Database Options

**Supported Databases**: Sinatra works with PostgreSQL, MariaDB/MySQL, and SQLite through database adapters.

**PostgreSQL** (recommended):
- Service type: `postgresql:18`
- URL scheme: `postgresql://`

**MariaDB/MySQL Alternative**:
- Service type: `mariadb:11.8`  
- URL scheme: `mysql://`

**SQLite** (development only):
- Remove database service and relationship
- Add writable mount for database file (typically `storage`)
- URL scheme: `sqlite3://`

---

Version numbers change over time. Verify against https://meta.upsun.com/images before committing configuration.
