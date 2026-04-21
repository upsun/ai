## Vue.js Application Configuration

Vue.js is a progressive JavaScript framework for building user interfaces and single-page applications.

### Build Process
- Modern Vue projects typically use Vite for build tooling.
- `npm run build` generates production site in the `dist/` directory (default).
- Projects may change the output directory via Vite config; update the `root` below if different.

### Production Deployment
- Avoid running development servers in production.
- Serve the `dist/` directory as static content for SPAs.
- SSR applications require a framework-specific server and are not covered by this static example.

### Example Upsun application config (Vite / SPA)
```yaml
applications:
  app:
    # Optional: uncomment and set if the application is not at the repository root
    # source:
    #   root: path/to/source

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
            "\\.(css|js|gif|jpe?g|png|svg|webp)$":
              expires: 4w
```

### Configuration Details
- Node.js Version: use nodejs:22 as the runtime.
- Package management: uses `npm ci --omit=dev` for deterministic production installs.
- Build script: requires a `build` script in `package.json` that produces the `dist/` output.
- Static site serving: the process is a no-op (`sleep infinity`) so static files are served without running a server process.
- Output directory: serves from `dist/` by default (Vite/Vue CLI default). Update `root` if your build outputs elsewhere.
- Caching strategy:
  - HTML content: 24-hour expiration.
  - Static assets: 4-week expiration for optimal caching.
- Security: server-side scripts disabled (`scripts: false`) for static content.
- SPA routing: for Vue Router (history mode), ensure the platform provides a fallback to `index.html` for client-side routes (the `index: [index.html]` entry handles this).

### Package Manager Support
- Match the project's package manager by checking for lockfiles (`package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`).
- To opt into pnpm for the runtime image, add:

```yaml
dependencies:
  nodejs:
    pnpm: "*"
```

This reference shows a minimal, production-ready static deployment for Vue.js SPAs built with Vite. For SSR or advanced server configurations, use a server application type and adapt build/run hooks accordingly.
