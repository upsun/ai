## Rails Application Configuration

Reference configuration for Ruby on Rails web applications on Upsun.

**Template Usage**: Customize configuration for specific Rails version and project requirements. Do not include explanatory comments in production configurations.

```yaml
applications:
  myapp:
    type: ruby:3.4

    hooks:
      build: |
        set -ex
        # Install Node.js dependencies if package.json exists
        if [ -f "package.json" ]; then
          npm install
        fi

        bundle install
        bundle exec rails assets:precompile

        # Database URL configuration for Rails auto-discovery
        echo >> .environment 'export DATABASE_URL="mysql://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'

      deploy: |
        set -ex
        bundle exec rails db:migrate

    web:
      commands:
        start: bundle exec rails server

      locations:
        /:
          root: public
          passthru: true
          expires: 1h

    # Add workers for background job processing if needed (only Rails 8 and above)
    workers:
      jobs:
        commands:
          start: bundle exec bin/jobs start
        variables:
          env:
            RAILS_ENV: production
            BUNDLE_WITHOUT: development:test


    variables:
      env:
        PIDFILE: tmp/server.pid
        RAILS_ENV: production
        BUNDLE_WITHOUT: development:test

    mounts:
      log:
        source: tmp
      storage:
        source: storage
      tmp:
        source: tmp

    relationships:
      db: {}

services:
  db:
    type: mariadb:11.4
    # this configuration is needed only if workers jobs are added
    configuration:
      schemas:
        - main
        - main_cache
        - main_queue
        - main_cable
      endpoints:
        mysql:
          default_schema: main
          privileges:
            main: admin
            main_cache: admin
            main_queue: admin
            main_cable: admin
```

**Configuration Details**:

- **Ruby Version**: Use exact version from Registry matching Rails requirements
- **Bundle Configuration**: BUNDLE_WITHOUT excludes development/test dependencies
- **Asset Compilation**: Rails assets precompiled during build phase
- **Database URL**: Automatic Rails database configuration via environment variable
- **File Management**: Persistent mounts for storage and logs, temporary for cache
- **Port Handling**: Rails server automatically uses `$PORT` environment variable

### Database Options

**Supported Databases**: Rails supports MySQL/MariaDB, PostgreSQL, and SQLite. Check `config/database.yml` for project requirements.

**Database URL configuration for Rails auto-discovery with mariadb**:
- For Rails version before **Rails 8** on the build hook replace the DATABASE_URL with this:

```
echo >> .environment 'export DATABASE_URL="mysql2://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'
```

- Cannot use `$DB_SCHEME` variable - must specify exact scheme

**MariaDB/MySQL** (recommended):
- Service type: `mariadb:11.4`

**PostgreSQL Alternative**:
- Service type: `postgresql:16`
- URL scheme: `postgresql://`

**SQLite** (discouraged for production):
- Remove database service and relationship
- Add writable mount for database file (typically `storage`)
- URL scheme: `sqlite3://`
- Requires persistent storage mount for database file access
