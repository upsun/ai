## Ruby Application Configuration

General configuration patterns for Ruby applications on Upsun.

### JavaScript Asset Dependencies

If a package.json is present, install Node.js dependencies in the build hook:

```bash
# Add to build hook when package.json detected
npm install  # or yarn install if using Yarn
```

### Database Connection

Most Ruby applications accept a DATABASE_URL environment variable. Add it to the .environment file in the build hook for database-enabled apps:

```bash
# Add to build hook for database-enabled applications
echo 'export DATABASE_URL="$DB_SCHEME://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"' >> .environment
```

### Background Job Processing

When background job gems are detected, add worker processes. Examples:

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

Standard production environment variables (use RACK_ENV for non-Rails apps):

```yaml
variables:
  env:
    BUNDLE_WITHOUT: development:test
    RAILS_ENV: production  # Use RACK_ENV for non-Rails apps
```
