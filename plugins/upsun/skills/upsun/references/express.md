## Express Application Configuration

Express.js is a minimal and flexible Node.js web application framework.

## Server Configuration

- Express applications run as persistent server processes
- Must listen on the port specified by the PORT environment variable
- Requires a start script that accepts port configuration (use process.env.PORT)

## Template Usage

Extend the Node.js base configuration with Express-specific server requirements. See Node.js guidance for package management and dependencies.

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

    web:
      commands:
        start: npm start

      locations:
        /:
          root: public
          passthru: true
          allow: false

        ^/(api|health):
          passthru: true
```

## Configuration Details

- Start Script: Configure your Express server to read the port from process.env.PORT and fall back to a sensible default when running outside the platform.
- Static Assets: Serve static assets from the public/ directory (Express default) with passthrough to the application where appropriate.
- API Routes: Route dynamic endpoints to the Express application (example pattern: ^/(api|health)).
- Security: Static directory access is disabled by default; explicitly enable only the paths you intend to expose.
- Build Process: Optionally include a build step for TypeScript compilation or asset bundling.

## Express Server Setup

```javascript
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
```

## Common Patterns

- API-only servers: remove static file serving and use passthru for all API routes
- Full-stack applications: combine with a frontend build process that writes to public/
- Microservices: run multiple small Express applications in a single repository as separate applications
