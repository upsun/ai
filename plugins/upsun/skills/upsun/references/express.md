## Express Application Configuration

Express.js is a minimal and flexible Node.js web application framework.

**Server Configuration**:
- Express applications run as persistent server processes
- Must listen on the port provided by the $PORT environment variable
- Requires a `start` script that uses the configured port

**Template Usage**: Extend the Node.js base configuration with these Express-specific server requirements. See Node.js guidance for package management and dependencies.

YAML example (minimal):

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

If your application source is in a repository subdirectory, add a source root, for example:

```yaml
applications:
  app:
    source:
      root: path/to/app
    type: nodejs:22
    # ...rest as above
```

**Configuration Details**:

- Start Script: Ensure your start script configures Express to use `process.env.PORT` (or a fallback) when calling `app.listen`.
- Static Assets: Serve static files from the `public/` directory. The example config uses passthrough so requests for static files are forwarded to the app process.
- API Routes: Route dynamic endpoints (e.g., `/api`) to the Express application using passthru locations.
- Security: Static directory access is disabled by default (`allow: false`) and only specific routes are allowed/passthrough.
- Build Process: Optional build step for TypeScript compilation, bundling, or asset generation is supported in the `build` hook.

**Express Server Setup (example)**:

```javascript
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
```

**Common Patterns**:
- API-only servers: omit static file serving and expose only API routes.
- Full-stack applications: combine with a frontend build step that emits assets to `public/`.
- Microservices: host multiple Express apps in the same repository by declaring multiple `applications:` entries.
