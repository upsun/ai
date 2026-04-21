## Vite Application Configuration

Vite is a modern build tool and development server supporting multiple JavaScript/TypeScript frameworks (React, Vue, Svelte, Nuxt).

### Build Process
- `vite build` generates a production site in the `dist/` directory (default).
- You can change the output directory with `--outDir`, but `dist/` is the common convention.

### Production Deployment
- Do not use `vite serve` or `vite preview` for production traffic.
- For simple sites, serve the `dist/` directory as static content from a lightweight web process.
- More complex framework integrations (Nuxt, SvelteKit with adapters) may require framework-specific server configuration; consult that framework's docs.

### Template usage
- Use Node.js 22 for builds and runtime.
- Ensure your package.json contains a `build` script that runs `vite build`.

```yaml
applications:
  site:
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
            '^\.(css|js|gif|jpe?g|png|svg|webp)$':
              expires: 4w
```

### Configuration details
- Node.js version: use Node.js 22 for builds and runtime.
- Package management: the example uses `npm ci --omit=dev` for deterministic production installs.
- Build script: ensure `package.json` has `"build": "vite build"` (or equivalent) so the build hook produces `dist/`.
- Static site serving: the process is a no-op (sleep infinity) because the platform serves files directly from `dist/`.
- Caching strategy:
  - HTML: 24-hour expiration.
  - Static assets (css/js/images): 4-week expiration for optimal caching.
- Security: server-side scripts are disabled for static locations (`scripts: false`).

### Notes & gotchas
- If your app is not at the repository root, add a `source.root` field pointing to the app subdirectory.
- If your framework produces a different output directory, update `root:` under `locations` accordingly.
- For server-rendered frameworks or apps requiring a Node server, replace the no-op start command and adjust build/runtime requirements.
