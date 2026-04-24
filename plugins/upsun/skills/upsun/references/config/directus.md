## Directus Application Configuration

Reference configuration for Directus applications on Upsun.

**Framework Priority**: Use Directus-specific configuration instead of generic Node.js guidance when both apply.

**Minimum Requirements**: Node.js 18+ required for Directus compatibility

**Template Usage**: Adapt database service and authentication configuration to project requirements. Exclude explanatory comments from production configurations.

```yaml
applications:
  directus:

    type: nodejs:24

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        npm install
        npm run argon2-rebuild

        # Write dynamic variables to .environment so they are exported at runtime.
        echo >> .environment 'export CACHE_ENABLED=true'
        echo >> .environment 'export CACHE_STORE=redis'
        echo >> .environment 'export REDIS_HOST=$REDIS_HOST'
        echo >> .environment 'export REDIS_PORT=$REDIS_PORT'
        echo >> .environment 'export RATE_LIMITER_ENABLED=true'
        echo >> .environment 'export RATE_LIMITER_STORE=redis'
        echo >> .environment 'export RATE_LIMITER_REDIS_HOST=$REDIS_HOST'
        echo >> .environment 'export RATE_LIMITER_REDIS_PORT=$REDIS_PORT'
        echo >> .environment 'export KEY=$PLATFORM_PROJECT_ENTROPY'
        echo >> .environment 'export SECRET=$PLATFORM_PROJECT_ENTROPY'

      deploy: |
        set -ex
        if [ ! -f var/upsun.installed ]; then
          echo 'Bootstrapping Directus on first deploy...'

          if [ -z "$ADMIN_EMAIL" ] || [ -z "$ADMIN_PASSWORD" ]; then
            echo >&2 'ADMIN_EMAIL and ADMIN_PASSWORD must be set before the first deploy.'
            echo >&2 'Set them with: upsun variable:create --name env:ADMIN_EMAIL --value <email> && upsun variable:create --name env:ADMIN_PASSWORD --value <password> --sensitive true'
            exit 1
          fi

          export PROJECT_NAME="${PROJECT_NAME:-Directus on Upsun}"

          npx directus bootstrap

          touch var/upsun.installed
        else
          npx directus database migrate:latest
        fi

    web:
      commands:
        start: npx directus start

    variables:
      env:
        NODE_ENV: production
        DB_CLIENT: pg
        EXTENSIONS_PATH: ./extensions
        UPLOADS_LOCATION: local
        UPLOADS_LOCAL_ROOT: ./uploads

    mounts:
      var:
        source: storage
      uploads:
        source: storage

    relationships:
      db: {}
      redis: {}

services:
  db:
    type: postgresql:18

  redis:
    type: redis:8.0

routes:
  https://{default}/:
    type: upstream
    upstream: directus:http
    cache:
      enabled: true
      default_ttl: 0
      cookies: ['*']
      headers: ['Accept', 'Accept-Language']

  https://www.{default}/:
    type: redirect
    to: https://{default}/
```

**Configuration Details**:

- **Database Service**: PostgreSQL service. Service named "db" exposes standard DB_ environment variables.
- **Caching**: Single Redis service for both application caching and rate limiting. Service named "redis" exposes standard REDIS_ environment variables.
- **Environment File**: Dynamic variables written to `.environment` file during build hook for proper substitution
- **Authentication**: Uses platform project entropy for key/secret generation ensuring unique values per environment
- **File Storage**: Local upload storage with persistent mount for file retention
- **First Deploy**: Bootstrap creates an admin user from `ADMIN_EMAIL` and `ADMIN_PASSWORD`, which must be set as Upsun variables before first deploy
- **Database Migration**: Automatic schema updates on subsequent deployments
- **Argon2 Rebuild**: Required dependency rebuild for password hashing compatibility
- **Upload Directory**: Persistent storage mount for file uploads with local storage driver
- **Extensions**: Support for custom Directus extensions in dedicated directory

**Security Notes**:
- Admin credentials come from `ADMIN_EMAIL` and `ADMIN_PASSWORD` Upsun variables; bootstrap fails fast if either is missing. Mark `ADMIN_PASSWORD` as sensitive when creating it.
- Project entropy provides cryptographically secure keys unique to each environment
- Database credentials managed automatically via service relationships
- File uploads restricted to designated mount for security isolation

**Build Process**:
1. Install Node.js dependencies including Directus core
2. Rebuild Argon2 native bindings for platform compatibility
3. Create `.environment` file with dynamic Redis and authentication variables
4. Bootstrap database and admin user on first deployment
5. Run schema migrations on subsequent deployments
6. Start Directus server with production configuration

---

Version numbers change over time. Verify against https://meta.upsun.com/images before committing configuration.
