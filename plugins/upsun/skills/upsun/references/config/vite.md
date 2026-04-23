## Vite Application Configuration

Vite is a modern build tool and development server supporting multiple JavaScript/TypeScript frameworks (React, Vue, Svelte, Nuxt).

Build Process:
- `vite build` generates the production site in the `dist/` directory (Vite default)
- A custom output directory can be used via `--outDir`, but `dist/` is common

Production Deployment:
- Do NOT use `vite serve` or `vite preview` in production
- For static sites, build with `vite build` and serve the `dist/` directory as static content
- More complex frameworks (SSR) may need framework-specific server configuration

Template example (minimal, static-site):

```yaml
applications:
  site:
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
        start: sleep infinity

      locations:
        '/':
          root: dist
          index: [index.html]
          scripts: false
          expires: 24h
          rules:
            '\.(css|js|gif|jpe?g|png|svg|webp)$':
              expires: 4w
```

Configuration Details:
- Node.js runtime: use a supported Node.js image from the Registry (example uses nodejs:24)
- Package management: `npm ci --omit=dev` for deterministic production installs
- Build script: package.json must provide a `build` script that runs `vite build`
- Static serving: a no-op start command (`sleep infinity`) is appropriate for purely static sites served via web.locations
- Output directory: `dist/` (default Vite) is the served root in the example
- Caching strategy:
  - HTML content: 24h expiration
  - Static assets (css/js/images): 4w expiration for long-lived caching
- Security: scripts execution disabled (`scripts: false`) for static content

Package manager notes:
- Example shows npm. If your project uses pnpm or yarn, install the matching manager via `dependencies.nodejs` and adapt hooks to use that tool (see standard Node.js guidance).

Gotchas and recommendations:
- Ensure `build` script in package.json runs `vite build` and that the build output is placed in `dist/` (or adjust `web.locations./.root` accordingly)
- Do not rely on the Vite dev server in production. Use the built static assets behind the Upsun web router or a framework-specific production server for SSR apps
- For multi-app projects (API + frontend), expose backend via relationships and set appropriate environment variables in the frontend using `.environment` in the build hook when needed

Verify registry versions:
- This reference uses `nodejs:24` (supported). Always verify image versions against the canonical registry before committing: https://meta.upsun.com/images
