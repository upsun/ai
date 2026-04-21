## Strapi Application Configuration

Strapi is a headless CMS built with Node.js that requires a database relationship for content storage and management.

### Database requirements

- PostgreSQL or MySQL service required (PostgreSQL recommended)
- Configure a `database` relationship (Upsun will populate connection env vars)
- Platform entropy is used to generate Strapi crypto secrets

### Template example

```yaml
applications:
  app:
    # If your application source is in a subdirectory, uncomment and set root
    # source:
    #   root: ./backend

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

### Configuration details

- Database service: PostgreSQL recommended (MySQL also supported).
- Security keys: Use `$PLATFORM_PROJECT_ENTROPY` to seed Strapi secrets (APP_KEYS, JWTs, salts).
- Production mode: `NODE_ENV=production` for optimized performance.
- Database client: Set via `DATABASE_CLIENT` (Upsun will also populate connection env vars from the `database` relationship).
- Admin panel: Accessible through Strapi's built-in interface when the app is running.
- Routes: The example uses passthru so all requests route to the Strapi application.

### Database setup & runtime behavior

- Upsun provides environment variables for the bound `database` relationship; Strapi will read these at startup to configure the connection.
- No manual database env var wiring is required when the relationship is present.
- Strapi runs any required schema migrations on startup (as part of its bootstrap).

### Common patterns & notes

- Content API: Serve headless content to frontend apps and clients.
- Admin-only CMS: Lock down the admin panel and expose only public APIs.
- Multi-environment: Use separate `database` services per branch/environment.

### Gotchas

- Ensure `NODE_ENV=production` and secrets are set in production; the example writes them into a `.environment` file using platform entropy.
- If your repository places the Strapi app in a subdirectory, set `source.root` to that path.
