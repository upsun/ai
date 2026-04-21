## Node.js Application Configuration

Reference configuration for Node.js applications on Upsun.

Template Usage:
- Adapt to specific project requirements and framework needs
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
        # This could use 'npm ci' (clean install), but only when package.json and package-lock.json are in sync.
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

Configuration Details:

- Runtime Version: Select appropriate Node.js version from Registry (example uses nodejs:22)
- Build Flavor: Use `none` for explicit control over the build process
- Build Script: Requires a `build` script in package.json
- Start Command: Requires a `serve` script accepting `--port` parameter
- Static Files: Adjust `root` to match your build output directory
- Dependencies: Install build tools needed during deployment (e.g., sass, sharp)

## Package Manager Support

Available Managers:
- npm: Pre-installed on all Node.js images
- bun and npx: Available on Node.js 20+
- pnpm / yarn: Require installation via `dependencies`

pnpm / yarn Setup:

```yaml
applications:
  example:
    type: nodejs:22
    build:
      flavor: none
    dependencies:
      nodejs:
        pnpm: '*'
    hooks:
      build: |
        set -ex
        pnpm install
        pnpm run build
    web:
      commands:
        start: pnpm run serve -- --port=$PORT
```

Selection Criteria:
- Match the project's existing package manager (check lock files)
- Use the same manager consistently across development and deployment

Gotchas / Notes:
- Using `build.flavor: none` gives you explicit control but requires fully specified build steps
- If using a package manager other than npm, ensure the manager is installed via the `dependencies` section
- Adjust the `locations./.root` and `web.commands.start` to match the actual build output and start script
