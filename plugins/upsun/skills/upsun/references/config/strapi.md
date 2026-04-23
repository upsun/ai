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
        '/':
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
- **Database Client**: Set automatically based on relationship service type
- **Admin Panel**: Accessible through Strapi's built-in interface
- **API Access**: All routes pass through to Strapi application

**Database Setup**:
- Strapi automatically configures database connection from the DATBASE_ variables Upsun provides for a relationship named `database`
- No manual environment variable configuration required
- Database migrations run during application startup

**Common Patterns**:
- Content API: Serve headless content to frontend applications
- Admin-only: Private CMS with external API consumption
- Multi-environment: Separate databases per environment branch

Note: Versions used above are taken from the local registry snapshot. Always verify runtime and service versions against the canonical registry before committing: https://meta.upsun.com/images
