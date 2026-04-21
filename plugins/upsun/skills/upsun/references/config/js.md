## Node.js Application Configuration

Reference configuration for Node.js applications on Upsun.

**Template Usage**:
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
        # Use a clean install suitable for CI; omit dev dependencies during deploy
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

**Configuration Details**:

- **Runtime Version**: nodejs:22 is used in these examples; select an appropriate Node.js version from Registry.
- **Build Flavor**: Use `none` for explicit control over the build process.
- **Build Script**: Requires a `build` script in package.json.
- **Start Command**: Requires a `serve` script that accepts a `--port` parameter.
- **Static Files**: Adjust `root` to match your build output directory (e.g., `dist`, `build`, `public`).
- **Dependencies**: Include build tools needed during deployment (e.g., `sass`, `sharp`).

## Package Manager Support

**Available Managers**:
- **npm**: Pre-installed on all Node.js images.
- **bun** and **npx**: Available on Node.js 20+ images.
- **pnpm / yarn**: Require installation via `dependencies`.

**pnpm / yarn Setup (example using pnpm)**:

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

**Selection Criteria**:
- Match the project's existing package manager (check for lock files: package-lock.json, pnpm-lock.yaml, yarn.lock).
- Use the same manager consistently across development and deployment to avoid lockfile mismatches.

## Gotchas / Notes
- The `npm install --omit=dev` approach assumes devDependencies are not required to build. If your build needs devDependencies, remove `--omit=dev` or install the necessary tools explicitly in `dependencies.nodejs`.
- Ensure your `serve` (or equivalent) script forwards the configured `$PORT` environment variable.
- Adjust `locations./.root` and `index` to reflect the actual output of your build step.
