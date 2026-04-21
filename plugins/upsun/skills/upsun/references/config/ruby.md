## Ruby Application Configuration

General configuration patterns for Ruby applications on Upsun.

### JavaScript Asset Dependencies

If your project includes a package.json, install Node.js dependencies during the build hook so asset compilation succeeds. Use Node.js 22 for builds that require Node.

Example build hook snippet:

```bash
# Add to build hook when package.json detected
npm install # or yarn install if using Yarn
```

### Database Connection

Most Ruby apps (Rails, Sinatra, etc.) understand a single DATABASE_URL environment variable. Add this in the build hook or deployment environment so runtime processes can connect to the database.

```bash
# Add to build hook for database-enabled applications
echo >> .environment 'export DATABASE_URL="$DB_SCHEME://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'
```

### Background Job Processing

When background job gems are present, add worker process definitions so Upsun can run them.

- Delayed::Job (when the `delayed` gem is present)
- Sidekiq (when the `sidekiq` gem is present)

Example workers configuration:

```yaml
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
```

Adjust process names and commands to match your app's setup (e.g., systemd/service wrappers or custom rake tasks).

### Standard Mounts

Common persistent mounts for Ruby applications (logs, uploads, tmp files):

```yaml
mounts:
  log:
    source: tmp
  storage:
    source: storage
  tmp:
    source: tmp
```

Ensure your app writes logs and uploaded files to these locations or adjust as needed.

### Production Environment

Typical production environment variables for Ruby apps (Rails uses RAILS_ENV; non-Rails apps may use RACK_ENV):

```yaml
variables:
  env:
    BUNDLE_WITHOUT: development:test
    RAILS_ENV: production # Use RACK_ENV for non-Rails apps
```

Usage notes / gotchas:
- If you compile assets with Webpacker or similar, ensure the Node install step runs before asset compilation.
- For Sidekiq, ensure Redis is available and configured via REDIS_URL.
- Keep secrets and DB credentials out of code and injected via environment variables or Upsun secret management.
