## Vue.js Application Configuration

Vue.js is a progressive JavaScript framework for building user interfaces and single-page applications.

### Build process
- Modern Vue projects typically use Vite for build tooling.
- npm run build generates the production site in dist/ by default.
- Custom output directories are possible via Vite but uncommon; adjust web.locations.root if you change it.

### Production deployment
- Do not run development servers in production.
- Serve the built dist/ directory as static content for SPAs.
- Server-side rendering (SSR) apps require a different (server) configuration — this reference is for static SPA builds.

Template usage: adapt the Node.js runtime version and verify the build script in package.json.

```yaml
applications:
  app:
    # If your app is in a subdirectory, add a source.root mapping here. Omit if the app is at repository root.
    # source:
    #   root: frontend

    type: nodejs:24

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        npm ci --omit=dev
        npm run build

    web:
      commands:
        # Static site: no long-running process required.
        start: sleep infinity

      locations:
        /:
          root: dist
          index: [index.html]
          scripts: false
          expires: 24h
          rules:
            '\.(css|js|gif|jpe?g|png|svg|webp)$':
              expires: 4w
```

Configuration details
- Node.js version: use nodejs:24 (from Registry snapshot).
- Package management: the build hook uses npm ci --omit=dev for deterministic production installs.
- Build script: ensure a build script exists in package.json that outputs the production site to dist/.
- Static site serving: use start: sleep infinity to avoid running a server process for static content.
- Output directory: dist/ (Vue CLI / Vite default). Update web.locations.root if your build uses a different folder.
- Caching strategy:
  - HTML content: 24-hour expiry.
  - Static assets (css/js/images): 4-week expiry.
- Security: scripts execution disabled for this static location (scripts: false).
- SPA routing: when using Vue Router in history mode, ensure the router/fallback configuration is compatible with static hosting (serve index.html for unknown routes).

Package manager support
- Pick the project’s existing package manager (check for package-lock.json, pnpm-lock.yaml, yarn.lock).
- pnpm/yarn must be added under dependencies to be available in the build image.

pnpm example
```yaml
applications:
  app:
    type: nodejs:24
    build:
      flavor: none
    dependencies:
      nodejs:
        pnpm: '*'
    hooks:
      build: |
        set -ex
        pnpm install
        pnpm run build
    web:
      commands:
        start: pnpm run serve -- --port=$PORT
      locations:
        '/':
          root: dist
          index: [index.html]
          scripts: false
```

Notes and gotchas
- Ensure the build produces an index.html at the location you configure; index: [index.html] will cause errors if the file is missing.
- If your project uses non-default paths (monorepo or subfolders), set source.root to the correct subdirectory.
- Use the same package manager in CI and local development to avoid lockfile mismatches.
- Do not hard-code secrets in examples; reference environment variables or use upsun variable:create for sensitive values.

Version verification
- This reference uses nodejs:24 (supported in the provided registry snapshot). Always verify runtime and service versions against the canonical registry before committing: https://meta.upsun.com/images
