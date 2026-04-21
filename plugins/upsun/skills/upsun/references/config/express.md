## Express Application Configuration

Express.js is a minimal and flexible Node.js web application framework.

### Server configuration
- Express applications run as persistent server processes.
- Must listen on the port specified by the $PORT environment variable.
- Requires a start script that respects process.env.PORT.

### Example Upsun application config
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
        "/":
          root: public
          passthru: true
          allow: false

        "^/(api|health)":
          passthru: true
```

Notes on the YAML:
- type: nodejs:22 uses the supported Node.js runtime.
- build.flavor none indicates a simple build; adjust for framework/tooling.
- locations map static files in public/ to passthrough to the app but disallow direct listing.

### Configuration details
- Start script: Configure Express to use process.env.PORT (see example below).
- Static assets: Serve from public/ with passthrough so Upsun forwards requests to the app when appropriate.
- API Routes: Use a passthru location for dynamic endpoints (example uses ^/(api|health)).
- Security: Static directory access is disabled by default (allow: false); open only required routes.
- Build process: Optional build step for TypeScript compilation or asset bundling; ensure npm run build exists if used in hooks.

### Express server setup
```javascript
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
```

### Common patterns
- API-only servers: Remove or omit static file locations and serve only API endpoints.
- Full-stack applications: Combine with frontend build process and emit built assets to public/.
- Microservices: Multiple Express applications can be defined in the same repository as separate Upsun applications (one per applications: entry).

### Gotchas & tips
- Ensure your npm start script starts the server without spawning background processes that detach from the main process.
- Always read PORT from process.env to let Upsun (and container environments) control the listening port.
- If your source code is not at the repository root, add a source.root entry under the application with the relative path.
