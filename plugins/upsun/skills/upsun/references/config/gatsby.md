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

- **Node.js Version**: Uses nodejs:24 from the Upsun image registry.
- **Package Installation**: Use `npm ci --omit=dev` for deterministic production builds when a package-lock.json is present and in sync; the build hook uses `npm install --omit=dev` when that cannot be guaranteed.
- **Build Process**: Executes Gatsby build script to generate static site in `public/` directory.
- **Runtime Server**: Uses `gatsby serve` (invoked via `npm run serve`) to serve pre-built static files.
- **Static Files**: Serves from `public/` directory containing Gatsby build output.
- **Cache Management**:
  - `.cache/data` mount provides writable storage for Gatsby runtime cache.
  - Avoid mounting the entire `.cache` directory — preserve build-time cache files.
- **Port Configuration**: Uses Upsun-provided PORT environment variable.

Note: Verify runtime and service versions against the canonical Upsun image registry before committing, at https://meta.upsun.com/images — image versions are deprecated and retired over time.
