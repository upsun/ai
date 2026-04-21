## Vue.js Application Configuration

Vue.js is a progressive JavaScript framework for building user interfaces and single-page applications.

### Build Process
- Modern Vue projects typically use Vite for build tooling.
- npm run build generates production site in dist/ directory (default).
- Some projects may change the output directory via Vite configuration; dist/ is the common default.

### Production Deployment
- Avoid running development servers in production.
- Serve the dist/ directory as static content for SPAs.
- Server-Side Rendering (SSR) applications require framework-specific server configuration and are not covered by this static-site example.

### Template (example)
- Node.js runtime: nodejs:22
- Build uses npm ci --omit=dev for deterministic production installations

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
            \.(css|js|gif|jpe?g|png|svg|webp)$:
              expires: 4w
```

### Configuration Details
- Node.js Version: Use nodejs:22 for runtime.
- Package Management: Uses npm ci --omit=dev for deterministic production installs.
- Build Script: Requires a build script in package.json that performs the production build (e.g., Vite build).
- Static Site Serving: The web process is a no-op (sleep infinity) so the platform only serves static files from the dist/ directory.
- Output Directory: Serves from dist/ by default (Vue CLI and Vite convention).
- Caching Strategy:
  - HTML content: 24-hour expiration.
  - Static assets (css/js/images): 4-week expiration for optimal performance.
- Security: Server-side scripts are disabled for static content (scripts: false).
- SPA Routing: For client-side routers (Vue Router), ensure the static server is configured to fallback to index.html so client-side routes resolve correctly.

### Package Manager Support
- Match the project's package manager by detecting lockfiles (package-lock.json, pnpm-lock.yaml, yarn.lock).
- If the project uses pnpm or yarn, enable the package manager in the nodejs dependency block. Example for pnpm:

```yaml
dependencies:
  nodejs:
    pnpm: "*"
```

Notes:
- This reference targets typical single-page Vue.js applications built with Vite or Vue CLI. SSR or custom server setups require additional configuration beyond static file serving.
