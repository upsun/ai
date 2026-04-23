## Ruby Application Configuration

General configuration patterns for Ruby applications on Upsun.

### Recommended runtime

When declaring an application runtime, pick a supported Ruby image from the Upsun registry. Example (pick the highest supported version available):

```yaml
applications:
  myapp:
    type: ruby:4.0
```

### JavaScript Asset Dependencies

If a package.json is present, install Node.js dependencies in the build hook:

```bash
# Add to build hook when package.json detected
npm install  # or yarn install if using Yarn
```

### Database Connection

Most Ruby applications accept DATABASE_URL environment variable. Write it into the app's .environment file from the build or deploy hook so it's available at runtime:

```bash
# Add to build hook for database-enabled applications
echo >> .environment 'export DATABASE_URL="$DB_SCHEME://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'
```

### Background Job Processing

When background job gems are detected, add worker processes.

```yaml
# Delayed::Job (when 'delayed' gem present)
workers:
  jobs:
    commands:
      start: bundle exec rake jobs:work
    variables:
      env:
        RAILS_ENV: production

# Sidekiq (when 'sidekiq' gem present)
workers:
  sidekiq:
    commands:
      start: bundle exec sidekiq
    variables:
      env:
        RAILS_ENV: production
```

### Standard Mounts

Common mount configuration for Ruby applications (adjust paths to your app layout):

```yaml
mounts:
  log:
    source: tmp
  storage:
    source: storage
  tmp:
    source: tmp
```

### Production Environment

Standard production environment variables for Rails apps (quote values that contain a colon):

```yaml
variables:
  env:
    BUNDLE_WITHOUT: 'development:test'
    RAILS_ENV: production  # Use RACK_ENV for non-Rails apps
```

### Minimal Example Application

A minimal example showing common patterns (build hook installs gems and optional JS deps, web start command, mounts, and a DB relationship). If you declare relationships, ensure a matching service exists under `services:`.

```yaml
applications:
  app:
    type: ruby:4.0
    build:
      flavor: none
    hooks:
      build: |
        set -ex
        # Install Ruby gems suitable for deployment
        bundle install --deployment --without development test
        # Install JS deps if present
        if [ -f package.json ]; then
          npm install
        fi
    web:
      commands:
        start: bundle exec puma -C config/puma.rb
      locations:
        '/':
          root: public
          passthru: true
    mounts:
      log:
        source: tmp
      storage:
        source: storage
    variables:
      env:
        BUNDLE_WITHOUT: 'development:test'
        RAILS_ENV: production
    relationships:
      database: {}

services:
  database:
    type: postgresql:18
```

Note: verify runtime and service versions against the canonical registry before committing, as versions are deprecated or retired over time:

https://meta.upsun.com/images
