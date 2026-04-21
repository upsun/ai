## Node.js Application Configuration

Reference configuration for Node.js applications on Upsun.

**Template usage**:
- Adjust to specific project requirements and framework needs
- Node.js applications often require multi-service architectures (frontend/backend, databases)
- Framework-specific configurations may extend this base template

```yaml
applications:
  example:
    type: nodejs:22

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        # This could use 'npm ci' (clean install), but only when package.json and package-lock.json are in sync (not possible to detect here).
        npm install --omit=dev
        npm run build

    web:
      commands:
        start: npm run serve -- --port=$PORT

      locations:
        /:
          root: public
          passthru: true
          index: [index.html]

    dependencies:
      nodejs:
        sass: "*"
```

Configuration details:

- Runtime Version: use nodejs:22 (select an appropriate Node.js version from the Registry)
- Build Flavor: Use `none` for explicit control over build process
- Build Script: Requires a `build` script in package.json
- Start Command: Requires a `serve` script accepting a `--port` parameter
- Static Files: Adjust `root` to match build output directory
- Dependencies: Install build tools needed during deployment (e.g., sass, sharp)

## Package Manager Support

Available managers:
- npm: Pre-installed on all Node.js images
- bun and npx: Available on Node.js 20+
- pnpm/yarn: Require installation via `dependencies`

pnpm/yarn setup example:

```yaml
applications:
  example:
    type: nodejs:22
    build:
      flavor: none
    dependencies:
      nodejs:
        pnpm: "*"
    hooks:
      build: |
        set -ex
        pnpm install
        pnpm run build
    web:
      commands:
        start: pnpm run serve -- --port=$PORT
```

Selection criteria:
- Match the project's existing package manager (check lock files)
- Use the same manager consistently across development and deployment
