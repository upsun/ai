## Vue.js Application Configuration

Vue.js is a progressive JavaScript framework for building user interfaces and single-page applications.

**Build Process**:
- Modern Vue projects typically use Vite for build tooling
- `npm run build` generates production site in `dist/` directory (default)
- Custom output directory via Vite configuration (uncommon)

**Production Deployment**:
- Avoid development servers in production
- Serve `dist/` directory as static content for SPAs
- SSR applications may require framework-specific server configurations

**Template Usage**: Adapt Node.js version and verify build script configuration in package.json.

```yaml
applications:
  app:
    

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
- **Build Script**: Requires `build` script in package.json that executes build process
- **Static Site Serving**: No-op process for CPU-efficient static content delivery
- **Output Directory**: Serves from `dist/` directory (Vue CLI/Vite default)
- **Caching Strategy**:
  - HTML content: 24-hour expiration
  - Static assets: 4-week expiration for optimal performance
- **Security**: Server-side scripts disabled for static content
- **SPA Routing**: For Vue Router, ensure proper fallback configuration for client-side routing

**Package Manager Support**:
- Match project's existing package manager (check for package-lock.json, pnpm-lock.yaml, yarn.lock)
- For pnpm/yarn, add to dependencies section:

```yaml
dependencies:
  nodejs:
    pnpm: "*"
```

---

Version numbers change over time. Verify against https://meta.upsun.com/images before committing configuration.
