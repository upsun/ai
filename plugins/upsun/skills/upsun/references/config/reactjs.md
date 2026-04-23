## React Application Configuration

React applications require Node.js runtime configuration with appropriate build tooling.

Configuration Approach: Use standard Node.js configuration patterns, adapting for:

- Build Tools: Vite, Webpack, Create React App (CRA), or custom build systems
- Package Managers: npm, bun or npx (available by default on images 20+), or pnpm/yarn (require installing)
- Static Serving: Build output directory (commonly `build/` for CRA or `dist/` for Vite)

Reference: Apply Node.js per-group guidance with framework-specific build commands and static file serving configuration.

Supported runtime used in examples: nodejs:24

Important: Verify image and service versions against the canonical registry before committing: https://meta.upsun.com/images

---

## Recommended Upsun configurations

Below are minimal, copy-paste-ready examples for common React setups. Adjust `source.root`, scripts and package manager to match your project.

Example 1 — Create React App (CRA) — static site served from `build/`:

```yaml
applications:
  frontend:
    type: nodejs:24

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        # Install production dependencies and build the app
        npm install --omit=dev
        npm run build

        # Write derived environment values if needed
        echo >> .environment 'export SITE_URL="$(echo $PLATFORM_ROUTES | base64 -d | jq -r 'to_entries[] | select(.value.primary == true) | .key')"'

    web:
      # For a purely static build, keep the container alive but let the router serve files
      commands:
        start: sleep infinity

      locations:
        '/':
          root: build
          index: [index.html]
          passthru: true

    dependencies:
      nodejs:
        sass: '*'
```

Notes:
- This configuration relies on the router serving static files from the `build` directory. The app container is left idle (sleep infinity).
- Ensure your package.json contains a `build` script that produces `build/index.html`.

Example 2 — Vite (modern tooling) — static site served from `dist/`:

```yaml
applications:
  frontend:
    type: nodejs:24

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        npm ci
        npm run build

        echo >> .environment 'export SITE_URL="$(echo $PLATFORM_ROUTES | base64 -d | jq -r 'to_entries[] | select(.value.primary == true) | .key')"'

    web:
      commands:
        start: sleep infinity

      locations:
        '/':
          root: dist
          index: [index.html]
          passthru: true

    dependencies:
      nodejs:
        sharp: '*'
```

Example 3 — Vite with pnpm (if your repo uses pnpm) — install pnpm as a dependency and use it in hooks:

```yaml
applications:
  frontend:
    type: nodejs:24

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

        echo >> .environment 'export SITE_URL="$(echo $PLATFORM_ROUTES | base64 -d | jq -r 'to_entries[] | select(.value.primary == true) | .key')"'

    web:
      commands:
        start: pnpm run serve -- --port=$PORT

      locations:
        '/':
          root: dist
          index: [index.html]
          passthru: true
```

Notes on package managers:
- npm is preinstalled on all Node.js images — prefer it if your repository uses package-lock.json.
- bun and npx are available on modern Node images (20+). On Upsun use the image-provided tools or install manager-specific tooling via `dependencies.nodejs`.
- If you add `pnpm` or `yarn` to `dependencies.nodejs`, ensure your build hooks use that manager consistently.

Configuration details and gotchas:
- Runtime version: examples use nodejs:24 (the highest supported Node.js runtime in the registry snapshot). Always confirm the appropriate version for your project and the canonical registry.
- Build flavor: use `none` and perform explicit build steps in the `hooks.build` script for reproducibility.
- Static root: set `web.locations['/'].root` to match your build output (`build` or `dist`). The `index` array should include `index.html` when present.
- Start command: for purely static apps served by the router, set `start: sleep infinity`. If you run a server to serve static files (e.g. `serve`), provide a `start` command that accepts the `$PORT` variable.
- Dependencies: list build-time tools under `dependencies.nodejs` (e.g. `sass`, `sharp`, `pnpm`). These are installed before `hooks.build` runs.

Remember
- Verify runtime and service versions at: https://meta.upsun.com/images before committing — versions can be deprecated or retired.
- Match the package manager to your repo’s lock files and use it consistently in build and start hooks.
- Ensure `web.locations` paths begin with `/` and regex keys (if used) are single-quoted.
