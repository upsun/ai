## Rails Application Configuration

Reference configuration for Ruby on Rails web applications on Upsun.

Template usage: customize configuration for specific Rails version and project requirements. Do not include explanatory comments in production configurations.

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

## Configuration Details

- Ruby Runtime: use the registry runtime matching Rails requirements (example above uses ruby:3.4).
- Bundle configuration: BUNDLE_WITHOUT excludes development/test dependencies in production.
- Asset compilation: Rails assets are precompiled during the build phase.
- Database URL: Rails can auto-discover database configuration when DATABASE_URL is set.
- File management: Persistent mounts for storage and logs; tmp mount for temporary files.
- Port handling: Rails server uses the $PORT environment variable automatically.

### Database Options

Supported databases: Rails supports MySQL/MariaDB, PostgreSQL, and SQLite. Check config/database.yml for project requirements.

Database URL configuration for Rails auto-discovery with MariaDB/MySQL:
- Default example (recommended for modern Rails):
  echo >> .environment 'export DATABASE_URL="mysql://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'

- For Rails versions before Rails 8, use the mysql2 scheme instead:
  echo >> .environment 'export DATABASE_URL="mysql2://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'

- Do not rely on a generic $DB_SCHEME variable; specify the exact scheme.

MariaDB/MySQL (recommended):
- Service type: mariadb:11.4

PostgreSQL alternative:
- Service type: postgresql:16
- URL scheme: postgresql://

SQLite (discouraged for production):
- Remove the database service and relationship
- Add a writable persistent mount for the database file (commonly storage)
- URL scheme: sqlite3://
- Requires persistent storage mount for the database file to be preserved
