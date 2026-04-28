## Angular Application Configuration

Angular is a TypeScript-based web application framework for building single-page applications.

**Build Process**:
- Angular CLI (`ng build`) generates production output in `dist/{project-name}/browser/` (Angular 17+) or `dist/{project-name}/` (older versions)
- The `root` path in `web.locations` must match the actual build output directory
- Check `angular.json` for the `outputPath` setting to determine the correct output directory
- Production builds are triggered via `npm run build`

**Production Deployment**:
- Avoid development servers (`ng serve`) in production
- Serve the build output directory as static content
- SSR applications (Angular Universal / Angular SSR) require different server configurations with a persistent process

**Template Usage**: Adapt Node.js version, build output path, and package manager based on project structure.

```yaml
applications:
  app:
    

    type: nodejs:24

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        npm ci
        npm run build

    web:
      commands:
        start: sleep infinity

      locations:
        /:
          root: dist/my-app/browser  # Adjust: check angular.json outputPath (Angular 17+: dist/{name}/browser/, older: dist/{name}/)
          index: [index.html]
          scripts: false
          expires: 24h
          rules:
            \.(css|js|gif|jpe?g|png|svg|webp)$:
              expires: 4w
```

**Configuration Details**:

- **Node.js Version**: Use latest available version from Registry
- **Package Management**: Uses `npm ci` for deterministic builds (devDependencies included for Angular CLI tooling)
- **Build Script**: Requires `build` script in package.json that executes `ng build`
- **Static Site Serving**: No-op process for CPU-efficient static content delivery
- **Output Directory**: Serves from `dist/my-app/browser/`; adjust to match Angular build output (check `angular.json` for `outputPath`)
  - Angular 17+: typically `dist/{project-name}/browser/`
  - Older Angular: typically `dist/{project-name}/`
- **Caching Strategy**:
  - HTML content: 24-hour expiration
  - Static assets: 4-week expiration for optimal performance
- **Security**: Server-side scripts disabled for static content
- **SPA Routing**: Angular Router requires proper fallback via `index: [index.html]` for client-side routing

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
