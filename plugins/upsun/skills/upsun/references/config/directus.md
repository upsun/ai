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

        # Create .environment file with dynamic variables
        cat > .environment <<EOF
        CACHE_ENABLED=true
        CACHE_STORE=redis
        REDIS_HOST=$REDIS_HOST
        REDIS_PORT=$REDIS_PORT
        RATE_LIMITER_ENABLED=true
        RATE_LIMITER_STORE=redis
        RATE_LIMITER_REDIS_HOST=$REDIS_HOST
        RATE_LIMITER_REDIS_PORT=$REDIS_PORT
        KEY=$PLATFORM_PROJECT_ENTROPY
        SECRET=$PLATFORM_PROJECT_ENTROPY
        EOF

      deploy: |
        set -ex
        if [ ! -f var/upsun.installed ]; then
          echo 'Bootstrapping Directus on first deploy...'

          # Provide admin credentials via Upsun variables rather than hard-coding them:
          # Set via: upsun variable:create --name env:ADMIN_EMAIL --sensitive false
          #          upsun variable:create --name env:ADMIN_PASSWORD --sensitive true
          export PROJECT_NAME='Directus on Upsun'
          export ADMIN_EMAIL="${ADMIN_EMAIL:?set via upsun variable:create}"
          export ADMIN_PASSWORD="${ADMIN_PASSWORD:?set via upsun variable:create}"

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

- **Runtime**: Node.js 24 runtime image (use Node.js 18+ for compatibility; runtime pinned here to a supported image).
- **Database Service**: PostgreSQL 18 service. Service named "db" exposes standard DB_ environment variables.
- **Caching**: Single Redis service for both application caching and rate limiting. Service named "redis" exposes standard REDIS_ environment variables.
- **Environment File**: Dynamic variables written to `.environment` file during build hook for proper substitution.
- **Authentication**: Uses platform project entropy for key/secret generation ensuring unique values per environment. Admin credentials should be provided via Upsun variables (see build/deploy comments) rather than hard-coded values.
- **File Storage**: Local upload storage with persistent mount for file retention.
- **First Deploy**: Automated bootstrap process creates admin user on initial deployment (deploy hook). Use Upsun variables to supply admin email/password in production.
- **Database Migration**: Automatic schema updates on subsequent deployments using Directus migration command.
- **Argon2 Rebuild**: Required dependency rebuild for password hashing compatibility.
- **Upload Directory**: Persistent storage mount for file uploads with local storage driver.
- **Extensions**: Support for custom Directus extensions in dedicated directory.

**Security Notes**:
- Do not commit admin credentials to the repository. Use Upsun variables (sensitive=true for passwords).
- Project entropy provides cryptographically secure keys unique to each environment.
- Database credentials managed automatically via service relationships.
- File uploads restricted to designated mount for security isolation.

**Build Process**:
1. Install Node.js dependencies including Directus core
2. Rebuild Argon2 native bindings for platform compatibility
3. Create `.environment` file with dynamic Redis and authentication variables
4. Bootstrap database and admin user on first deployment (deploy hook)
5. Run schema migrations on subsequent deployments
6. Start Directus server with production configuration

Note: Always verify and, if needed, update image versions against the canonical registry before committing: https://meta.upsun.com/images
