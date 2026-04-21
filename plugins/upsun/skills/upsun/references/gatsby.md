## Gatsby Application Configuration

Reference configuration for Gatsby static site applications on Upsun.

**Framework Overview**: React-based static site generator with SSR support and dynamic data fetching capabilities.

**Template Usage**: Adapt configuration to project-specific build tools and deployment requirements. Do not include explanatory comments in production configurations.

```yaml
applications:
  site:
    type: nodejs:22

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        # This could use 'npm ci' (clean install), but only when package.json and package-lock.json are in sync (not possible to detect here).
        npm install --omit=dev
        npm run build

    web:
      commands:
        start: npm run serve -- --port=$PORT

      locations:
        /:
          root: public
          passthru: true
          index: [index.html]

    mounts:
      .cache/data:
        source: tmp
```

## Configuration Details

- Node.js Version: nodejs:22 (use the Registry-provided Node.js runtime).
- Package Installation: Use `npm ci --omit=dev` for deterministic production builds when a package-lock.json is present; template uses `npm install --omit=dev` when lockfile consistency cannot be assumed.
- Build Process: Executes the Gatsby build script to generate static assets in the `public/` directory.
- Runtime Server: Uses `gatsby serve` (invoked here as `npm run serve`) to serve pre-built static files.
- Static Files: Serve from the `public/` directory containing Gatsby build output.
- Cache Management:
  - Mount only `.cache/data` to provide writable storage for Gatsby runtime cache.
  - Avoid mounting the entire `.cache` directory to preserve build-time cache files used during builds.
- Port Configuration: Uses the Upsun-provided PORT environment variable (`$PORT`) for the runtime web command.
