## Ruby Application Configuration

General configuration patterns for Ruby applications on Upsun.

### JavaScript Asset Dependencies

If your repository includes a package.json, install Node.js dependencies during the build hook. Add a step that runs the appropriate installer:

```bash
# Add to your build hook when package.json is present
npm install    # or: yarn install
```

### Database Connection

Most Ruby applications (Rails and many frameworks/libraries) use the DATABASE_URL environment variable. Set it during build or start so the app can read it at runtime.

```bash
# Example: append a DATABASE_URL export to the .environment file
echo 'export DATABASE_URL="$DB_SCHEME://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"' >> .environment
```

### Background Job Processing

When background job gems are detected, define worker processes. Minimal examples:

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

Adjust worker counts and resources in your main Upsun config as needed.

### Standard Mounts

Common mounts for Ruby apps (logs, storage, tmp):

```yaml
mounts:
  log:
    source: tmp
  storage:
    source: storage
  tmp:
    source: tmp
```

These ensure persistence for logs, file uploads, and temporary data across deploys.

### Production Environment

Standard production environment variables for Ruby apps:

```yaml
variables:
  env:
    BUNDLE_WITHOUT: development:test
    RAILS_ENV: production  # use RACK_ENV for non-Rails apps
```

Notes and gotchas:
- Use RACK_ENV instead of RAILS_ENV for non-Rails Rack apps.
- Ensure the build hook installs any native npm packages before asset compilation.
- Confirm that DATABASE_URL values are populated from the platform-provided secrets or service bindings at runtime.
