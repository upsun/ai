## Vite Application Configuration

Vite is a modern build tool and development server supporting multiple JavaScript/TypeScript frameworks (React, Vue, Svelte, Nuxt).

Build Process:
- `vite build` generates production site in `dist/` directory (default)
- Custom output directory via `--outDir` flag (uncommon)

Production Deployment:
- Avoid `vite serve` and `vite preview` development servers in production
- Serve the `dist/` directory as static content for simple sites
- Complex frameworks may require framework-specific server configurations

Template usage: set Node.js runtime to nodejs:22 and ensure your package.json has a `build` script that runs `vite build`.

```yaml
applications:
  site:
    # If your application lives in a subdirectory of the repo, uncomment and set the path below:
    # source:
    #   root: path/to/app

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
            '\.(css|js|gif|jpe?g|png|svg|webp)$':
              expires: 4w
```

Configuration Details:

- Node.js Version: Use nodejs:22 runtime
- Package Management: Uses `npm ci --omit=dev` for deterministic production installs
- Build Script: Requires a `build` script in package.json that executes `vite build`
- Static Site Serving: The process is a no-op (sleep) so the platform can efficiently serve static content
- Output Directory: Serves from `dist/` (Vite default)
- Caching Strategy:
  - HTML content: 24-hour expiration
  - Static assets: 4-week expiration for optimal performance
- Security: Server-side scripts disabled for static content

Gotchas / Notes:
- Do not run `vite preview` or `vite serve` for production traffic
- If your framework produces server-side output (SSR), follow framework-specific server configuration instead of static serving
- If you change Vite's outDir, update the `root` in the location block accordingly
