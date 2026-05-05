## Strapi Application Configuration

Strapi is a headless CMS built with Node.js that requires database connectivity for content management.

**Database Requirements**:
- PostgreSQL or MySQL service required
- Database relationship configured via service binding
- Environment variables automatically populated by Upsun

**Template Usage**: Extend Node.js base configuration with database service and Strapi-specific requirements. See Node.js guidance for package management.

```yaml
applications:
  app:

    type: nodejs:24

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        npm install --omit=dev
        npm run build
        # Generate Strapi secrets using platform entropy
        echo >> .environment 'export NODE_ENV=production'
        echo >> .environment 'export DATABASE_CLIENT=postgres'
        echo >> .environment 'export DATABASE_URL="$DATABASE_SCHEME://$DATABASE_USERNAME:$DATABASE_PASSWORD@$DATABASE_HOST:$DATABASE_PORT/$DATABASE_PATH"'
        echo >> .environment 'export APP_KEYS=$PLATFORM_PROJECT_ENTROPY'
        echo >> .environment 'export API_TOKEN_SALT=$PLATFORM_PROJECT_ENTROPY'
        echo >> .environment 'export ADMIN_JWT_SECRET=$PLATFORM_PROJECT_ENTROPY'
        echo >> .environment 'export TRANSFER_TOKEN_SALT=$PLATFORM_PROJECT_ENTROPY'
        echo >> .environment 'export JWT_SECRET=$PLATFORM_PROJECT_ENTROPY'

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
    type: postgresql:18
```

**Configuration Details**:

- **Database Service**: PostgreSQL recommended, MySQL also supported
- **Security Keys**: Uses `$PLATFORM_PROJECT_ENTROPY` for cryptographic secrets
- **Production Mode**: `NODE_ENV=production` for optimized performance
- **Database Client**: Set explicitly to `postgres` to match the PostgreSQL service
- **Admin Panel**: Accessible through Strapi's built-in interface
- **API Access**: All routes pass through to Strapi application

**Database Setup**:
- Upsun exposes the relationship named `database` as `DATABASE_*` environment variables (the prefix is the uppercased relationship name); the build hook combines these into the `DATABASE_URL` that Strapi expects
- Database migrations run during application startup

**Common Patterns**:
- Content API: Serve headless content to frontend applications
- Admin-only: Private CMS with external API consumption
- Multi-environment: Separate databases per environment branch

---

Version numbers change over time. Verify against https://meta.upsun.com/images before committing configuration.
