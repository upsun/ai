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

YAML example (minimal, static-site setup):

```yaml
applications:
  site:
    # If your repository places the app in a subdirectory, add a `source.root: <path>` entry here.
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
        # Static sites should use a no-op start to avoid running a dev server.
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

**Configuration Details**:

- **Node.js Version**: Use nodejs:24 (the current supported Node.js runtime in the Registry)
- **Package Management**: Uses `npm ci --omit=dev` for deterministic production builds
- **Build Script**: Requires a `build` script in package.json that executes `vite build`
- **Static Site Serving**: No-op process for CPU-efficient static content delivery (`start: sleep infinity`)
- **Output Directory**: Serves from `dist/` directory (Vite default)
- **Caching Strategy**:
  - HTML content: 24-hour expiration
  - Static assets: 4-week expiration for optimal performance
- **Security**: Server-side scripts disabled for static content (`scripts: false`)

Note: Confirm runtime and service versions against the canonical registry before committing, since versions are deprecated or retired over time: https://meta.upsun.com/images
