## Express Application Configuration

Express.js is a minimal and flexible Node.js web application framework.

**Server Configuration**:
- Express applications run as persistent server processes
- Must listen on port specified by the $PORT environment variable
- Requires a start script that accepts port configuration

**Template Usage**: Extend Node.js base configuration with Express-specific server requirements. See Node.js guidance for package management and dependencies.

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
        /:
          root: public
          passthru: true
          allow: false

        '^/(api|health)':
          passthru: true
```

**Configuration Details**:

- **Start Script**: Must configure Express to use `process.env.PORT` or default appropriately
- **Static Assets**: Serve from `public/` directory (Express default) with passthrough to application
- **API Routes**: Route dynamic endpoints to Express application
- **Security**: Static directory access disabled by default, only specific routes allowed
- **Build Process**: Optional build step for TypeScript compilation or asset bundling

**Express Server Setup**:
```javascript
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
```

**Common Patterns**:
- API-only servers: Remove static file serving
- Full-stack applications: Combine with frontend build process
- Microservices: Multiple Express applications in single project

Note: This reference uses the supported image nodejs:24. Always verify runtime and service versions against the canonical registry before committing: https://meta.upsun.com/images
