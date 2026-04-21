## Vue.js Application Configuration

Vue.js is a progressive JavaScript framework for building user interfaces and single-page applications.

### Build Process
- Modern Vue projects typically use Vite for build tooling
- `npm run build` generates production site in `dist/` directory (default)
- Custom output directory via Vite configuration is possible but uncommon

### Production Deployment
- Avoid development servers in production
- Serve the `dist/` directory as static content for SPAs
- SSR applications require framework-specific server configurations (not covered here)

### Example (repository root)
```yaml
applications:
  app:
    type: nodejs:22

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        npm ci --omit=dev
        npm run build

    web:
      commands:
        start: sleep infinity

      locations:
        /:
          root: dist
          index: [index.html]
          scripts: false
          expires: 24h
          rules:
            "\.(css|js|gif|jpe?g|png|svg|webp)$":
              expires: 4w
```

### Example (monorepo / app in subdirectory)
```yaml
applications:
  app:
    source:
      root: frontend

    type: nodejs:22

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        npm ci --omit=dev
        npm run build

    web:
      commands:
        start: sleep infinity

      locations:
        /:
          root: dist
          index: [index.html]
          scripts: false
          expires: 24h
          rules:
            "\.(css|js|gif|jpe?g|png|svg|webp)$":
              expires: 4w
```

### Configuration Details
- Node.js Version: use Node.js 22
- Package management: uses `npm ci --omit=dev` for deterministic production builds
- Build script: requires a `build` script in package.json that executes the build process
- Static site serving: a no-op process is used so the platform can efficiently serve static content
- Output directory: serves from `dist/` (Vue CLI/Vite default)
- Caching strategy:
  - HTML content: 24-hour expiration
  - Static assets: 4-week expiration for optimal performance
- Security: server-side scripts are disabled for static content
- SPA routing: for Vue Router, ensure proper fallback configuration to index.html for client-side routing

### Package Manager Support
- Match the project's existing package manager (check for package-lock.json, pnpm-lock.yaml, yarn.lock)
- If the project uses pnpm or Yarn, add the runtime dependency hint:

```yaml
dependencies:
  nodejs:
    pnpm: "*"
```
