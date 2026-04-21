## Vite Application Configuration

Vite is a modern build tool and development server supporting multiple JavaScript/TypeScript frameworks (React, Vue, Svelte, Nuxt).

### Build Process
- `vite build` generates the production site in the `dist/` directory (default).
- A custom output directory can be configured with the `--outDir` flag (uncommon).

### Production Deployment
- Do not use `vite serve` or `vite preview` in production.
- For simple/static sites, serve the built `dist/` directory as static content.
- Framework integrations (Nuxt, SvelteKit, etc.) may require framework-specific server configurations beyond static serving.

### Template Usage
- This reference uses Node.js runtime: nodejs:22. Verify your project build script in package.json uses `vite build`.

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
            "\.(css|js|gif|jpe?g|png|svg|webp)$":
              expires: 4w
```

### Configuration Details

- Node.js Version: Use Node.js 22 (nodejs:22) for builds and runtime.
- Package Management: Uses `npm ci --omit=dev` for deterministic production installs.
- Build Script: Your package.json must provide a `build` script that runs `vite build`.
- Static Site Serving: The app runs a no-op process (sleep infinity) and serves the `dist/` directory directly for CPU-efficient static delivery.
- Output Directory: Serves from `dist/` (Vite default).
- Caching Strategy:
  - HTML content: 24-hour expiration.
  - Static assets: 4-week expiration for long-lived cache.
- Security: Server-side scripts disabled for static content (scripts: false).

Usage notes / gotchas:
- If your project lives in a subdirectory of the repository, add a `source` block with `root: <path>` to point the application to the correct source directory.
- For framework-specific server builds (SSR, adapters, or node servers), replace the static-serving configuration with the appropriate server command and locations.
