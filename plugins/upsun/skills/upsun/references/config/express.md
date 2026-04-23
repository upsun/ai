## Express Application Configuration

Express.js is a minimal, flexible Node.js web framework.

Server Configuration:
- Runs as a persistent server process
- Must listen on the port in the $PORT environment variable
- Requires a start command that accepts/configures the port

Template usage: extend the Node.js runtime configuration with Express-specific server requirements. See Node.js guidance for package manager choices and dependency installation.

Example .upsun/config.yaml for an Express app:

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

    web:
      commands:
        start: npm start

      locations:
        '/':
          root: public
          passthru: true
          allow: false

        '^/(api|health)':
          passthru: true
```

Configuration details:
- Start script: Ensure your Express app reads process.env.PORT (or falls back to a default) and binds to it. The start command shown uses npm start and must forward the environment provided by Upsun.
- Static assets: Serve from the public/ directory; locations.root is set to public with passthru so dynamic routes continue to your app.
- API routes: Use a regex location (e.g. '^/(api|health)') to passthru dynamic endpoints to Express.
- Security: Serving static files is disabled by default for the root location (allow: false). Explicitly enable locations you want to expose.
- Build process: Include optional build step for TypeScript compilation or bundling; the example runs npm run build after installing production dependencies.

Express server setup (example):

```javascript
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
```

Common patterns:
- API-only servers: remove static file locations or set root and allow accordingly.
- Full-stack apps: combine an asset build step that emits to public/.
- Microservices: multiple Express applications may be defined in a single repository; ensure unique app names and routes.

Note: This reference uses the Upsun Node.js runtime image nodejs:24. Verify image types and versions against the canonical registry before committing, since versions are deprecated or retired over time: https://meta.upsun.com/images
