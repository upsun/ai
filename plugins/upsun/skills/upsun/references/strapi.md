## Strapi Application Configuration

Strapi is a headless CMS built with Node.js that requires database connectivity for content management.

**Database Requirements**:
- PostgreSQL or MySQL service required
- Database relationship configured via service binding
- Environment variables automatically populated by Upsun

**Template Usage**: Extend the Node.js base configuration (nodejs:22) with a database service and Strapi-specific build/runtime requirements. See Node.js guidance for package management (npm/yarn) and build steps.

Example application configuration (minimal, valid YAML):

```yaml
applications:
  app:
    type: nodejs:22

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        npm install --omit=dev
        npm run build
        # Generate Strapi secrets using platform entropy
        cat > .environment << EOF
        NODE_ENV=production
        DATABASE_CLIENT=postgres
        APP_KEYS=$PLATFORM_PROJECT_ENTROPY
        API_TOKEN_SALT=$PLATFORM_PROJECT_ENTROPY
        ADMIN_JWT_SECRET=$PLATFORM_PROJECT_ENTROPY
        TRANSFER_TOKEN_SALT=$PLATFORM_PROJECT_ENTROPY
        JWT_SECRET=$PLATFORM_PROJECT_ENTROPY
        EOF

    web:
      commands:
        start: npm start

      locations:
        /:
          passthru: true

    relationships:
      database: {}

services:
  database:
    type: postgresql:16
```

- If your code lives in a repository subdirectory, add a `source` block with a `root:` path pointing to that directory. Example:

```yaml
# add under app:
# source:
#   root: ./backend/strapi
```

Configuration Details
- Database Service: PostgreSQL (recommended) or MySQL. Example uses postgresql:16.
- Security Keys: Uses `$PLATFORM_PROJECT_ENTROPY` to populate Strapi cryptographic secrets (APP_KEYS, API_TOKEN_SALT, ADMIN_JWT_SECRET, TRANSFER_TOKEN_SALT, JWT_SECRET).
- Production Mode: `NODE_ENV=production` for optimized performance.
- Database Client: Set by `DATABASE_CLIENT` (postgres/mysql) — Upsun will populate connection variables for a relationship named `database`.
- Admin Panel: Accessible through Strapi's built-in interface.
- API Access: All routes pass through to the Strapi application via the passthru location.

Database Setup
- Strapi automatically configures the database connection from the `DATABASE_*` environment variables Upsun provides for a relationship named `database`.
- No manual environment variable configuration required for basic connectivity; secrets and connection info are injected from the platform.
- Database migrations/initialization are handled at application startup by Strapi (ensure your image/build runs needed bootstrap commands if you customize startup).

Common Patterns
- Content API: Serve headless content to frontend applications (static sites, SPAs, mobile apps).
- Admin-only: Use Strapi as a private CMS with external API consumption.
- Multi-environment: Provision separate databases per environment/branch and manage secrets via platform entropy.

Gotchas & Notes
- Ensure `npm run build` produces a production-ready build for Strapi v4+ (adjust scripts if using custom setups).
- If using MySQL/MariaDB, adapt `DATABASE_CLIENT` and service type accordingly (mariadb:11.4 supported).
- Keep cryptographic secrets secure — relying on `$PLATFORM_PROJECT_ENTROPY` ensures per-project randomness.
- If you require additional services (Redis, workers), define them as separate services and bind them with relationships; Upsun will provide connection variables.
