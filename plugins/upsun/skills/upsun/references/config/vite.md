## Vite Application Configuration

Vite is a modern build tool and development server supporting multiple JavaScript/TypeScript frameworks (React, Vue, Svelte, Nuxt).

**Build Process**:
- `vite build` generates production site in `dist/` directory (default)
- Custom output directory via `--outDir` flag (uncommon)

**Production Deployment**:
- Avoid `vite serve` and `vite preview` development servers in production
- Serve `dist/` directory as static content for simple sites
- Complex frameworks may require framework-specific server configurations

**Template Usage**: Adapt Node.js version and verify build script configuration in package.json.

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
        /:
          root: dist
          index: [index.html]
          scripts: false
          expires: 24h
          rules:
            \.(css|js|gif|jpe?g|png|svg|webp)$:
              expires: 4w
```

**Configuration Details**:

- **Node.js Version**: Use latest available version from Registry
- **Package Management**: Uses `npm ci --omit=dev` for deterministic production builds
- **Build Script**: Requires `build` script in package.json that executes `vite build`
- **Static Site Serving**: No-op process for CPU-efficient static content delivery
- **Output Directory**: Serves from `dist/` directory (Vite default)
- **Caching Strategy**:
  - HTML content: 24-hour expiration
  - Static assets: 4-week expiration for optimal performance
- **Security**: Server-side scripts disabled for static content

---

Version numbers change over time. Verify against https://meta.upsun.com/images before committing configuration.
