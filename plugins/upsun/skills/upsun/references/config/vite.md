## Vite Application Configuration

Vite is a modern build tool and development server supporting multiple JavaScript/TypeScript frameworks (React, Vue, Svelte, Nuxt).

### Build Process
- `vite build` generates a production site in the `dist/` directory (default).
- A custom output directory is possible via Vite's `--outDir`, but `dist/` is conventional.

### Production Deployment
- Do not use `vite serve` or `vite preview` as production servers.
- For simple/static sites, serve the generated `dist/` directory as static content.
- Framework integrations (Nuxt, SvelteKit, etc.) may require framework-specific servers — consult those framework docs.

### Template Usage
- Use Node.js 22 as the runtime.
- Ensure your package.json contains a `build` script that runs `vite build` (or your framework's equivalent).

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
          expires: "24h"
          rules:
            '\.(css|js|gif|jpe?g|png|svg|webp)$':
              expires: "4w"
```

### Configuration Details
- Node.js Version: Use Node.js 22 for builds and runtime.
- Package Management: `npm ci --omit=dev` provides deterministic production installs.
- Build Script: Your project must expose a `build` script in package.json that performs the Vite build.
- Static Site Serving: The application process is a no-op (`sleep infinity`) since content is served from `dist/` by the web layer.
- Output Directory: `dist/` is the default output and is served as the site root.
- Caching Strategy:
  - HTML: 24-hour expiration.
  - Static assets (CSS/JS/images/etc.): 4-week expiration for long-term caching.
- Security: Server-side script execution is disabled for static content locations.

### Gotchas
- Do not rely on development servers for production — always build and serve static output or use a proper framework server.
- If your project uses a different output directory, update `root:` accordingly in the `locations` section.
- If your build requires environment variables or additional build steps (e.g., installing global CLIs), add them to the `build` hook.
