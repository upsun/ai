## Express Application Configuration

Express.js is a minimal and flexible Node.js web application framework.

### Server Configuration
- Express applications run as persistent server processes
- Must listen on the port specified by the `PORT` environment variable
- Requires a `start` script that respects `process.env.PORT`

### Template (YAML)
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

### Configuration Details
- Start Script: Ensure your application uses `process.env.PORT` (or a clear default) when calling `app.listen()`
- Static Assets: Serve static files from `public/` (Express conventional location) with passthrough to the app
- API Routes: Dynamic endpoints (e.g., `/api/*`, `/health`) should be routed to the Express server
- Security: Static directory access is disabled by default; enable only the minimal set of routes needed
- Build Process: Optional build step is provided for TypeScript compilation or asset bundling

### Express Server Setup (example)
```javascript
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
```

### Common Patterns
- API-only servers: remove static file serving configuration
- Full-stack apps: combine backend with frontend build steps in `hooks.build`
- Microservices: run multiple Express applications in one repository by adding more `applications` entries
