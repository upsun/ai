## Ruby Application Configuration

General configuration patterns for Ruby applications on Upsun.

### JavaScript Asset Dependencies

If a package.json is present, install Node.js dependencies in the build hook:

```bash
# Add to build hook when package.json detected
npm install  # or yarn install if using Yarn
```

### Database Connection

Most Ruby applications accept a DATABASE_URL environment variable. Construct it in the build hook using the relationship-provided variables (the prefix is the uppercased relationship name):

```bash
# Add to build hook for database-enabled applications
echo >> .environment 'export DATABASE_URL="$DATABASE_SCHEME://$DATABASE_USERNAME:$DATABASE_PASSWORD@$DATABASE_HOST:$DATABASE_PORT/$DATABASE_PATH"'
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

Common mount configuration for Ruby applications:

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

Standard production environment variables:

```yaml
variables:
  env:
    BUNDLE_WITHOUT: 'development:test'
    RAILS_ENV: production  # Use RACK_ENV for non-Rails apps
```


## Minimal Upsun YAML example for a Rails app

This example shows a complete, minimal .upsun/config.yaml using the supported Ruby runtime. It includes build steps (Node + Bundler), a database relationship, Redis for Sidekiq, mounts, workers, and a default route.

```yaml
applications:
  app:
    type: ruby:4.0

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        npm install
        bundle install --without development test --path vendor/bundle
        echo >> .environment 'export DATABASE_URL="$DATABASE_SCHEME://$DATABASE_USERNAME:$DATABASE_PASSWORD@$DATABASE_HOST:$DATABASE_PORT/$DATABASE_PATH"'

    web:
      commands:
        start: bundle exec puma -C config/puma.rb
      upstream:
        socket_family: tcp
        protocol: http
      locations:
        '/':
          root: public
          passthru: true
          index: [index.html]

    mounts:
      log:
        source: tmp
      storage:
        source: storage
      tmp:
        source: tmp

    relationships:
      database: {}
      redis: {}

    variables:
      env:
        BUNDLE_WITHOUT: 'development:test'
        RAILS_ENV: production

    workers:
      jobs:
        commands:
          start: bundle exec rake jobs:work
        variables:
          env:
            RAILS_ENV: production

      sidekiq:
        commands:
          start: bundle exec sidekiq
        variables:
          env:
            RAILS_ENV: production

services:
  database:
    type: postgresql:18

  redis:
    type: redis:8.0

routes:
  https://{default}/:
    type: upstream
    upstream: app:http
```

Notes and gotchas

- If your Ruby app includes frontend assets managed by npm/Yarn, install them during the build step (see the JavaScript Asset Dependencies section).
- Use the build hook to write a .environment file for dynamic values (service-derived URLs, computed SITE_URL, feature flags, etc.).
- Ensure any service referenced in relationships has a corresponding service definition (or an application with that name); otherwise the relationship environment variables will not be injected.

Remember to verify runtime and service versions against the canonical registry before committing: https://meta.upsun.com/images
