## Gatsby Application Configuration

Reference configuration for Gatsby static site applications on Upsun.

**Framework Overview**: React-based static site generator with SSR support and dynamic data fetching capabilities.

**Template Usage**: Adapt configuration to project-specific build tools and deployment requirements. Do not include explanatory comments in production configurations.

```yaml
applications:
  site:

    type: nodejs:24

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

**Configuration Details**:

- **Node.js Version**: Use latest available version from Registry for optimal performance
- **Package Installation**: Use `npm ci --omit=dev` for deterministic production builds with package-lock.json
- **Build Process**: Executes Gatsby build script to generate static site in `public/` directory  
- **Runtime Server**: Uses `gatsby serve` command to serve pre-built static files
- **Static Files**: Serves from `public/` directory containing Gatsby build output
- **Cache Management**: 
  - `.cache/data` mount provides writable storage for Gatsby runtime cache
  - Avoid mounting entire `.cache` directory - preserves build-time cache files
- **Port Configuration**: Uses Upsun-provided PORT environment variable

---

Version numbers change over time. Verify against https://meta.upsun.com/images before committing configuration.
