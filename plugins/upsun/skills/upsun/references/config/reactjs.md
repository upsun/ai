## React Application Configuration

React applications require a Node.js runtime and an explicit build step that emits static assets (often into `build/` or `dist/`). Use the Node.js per-group guidance and adapt web.locations.root to the framework's build output.

Configuration approach

- Runtime: nodejs:24 (see registry snapshot)
- Build flavor: none — run the exact install/build commands you need in the build hook
- Common build tools: Vite, Webpack, Create React App, or custom scripts
- Static serving: set web.locations./.root to the directory produced by your build (e.g. `build` for CRA, `dist` for Vite)
- For entirely static sites (served only via web.locations) set web.commands.start: sleep infinity

Notes

- Ensure your repository has the appropriate `build` script in package.json (e.g. `npm run build`).
- If your project uses pnpm or yarn, install them via dependencies to ensure the correct CLI is available during build (see pnpm example below).
- Verify runtime and service versions at the canonical registry before committing: https://meta.upsun.com/images

Examples

1) Create React App (static output in `build/`)

```yaml
applications:
  frontend:
    type: nodejs:24

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        npm install --omit=dev
        npm run build

    web:
      # Static-only site: no runtime server needed.
      commands:
        start: sleep infinity

      locations:
        /:
          root: build
          index: [index.html]
          passthru: true

    # If you need build-time tools (e.g. sass, sharp) add them under dependencies.nodejs
    dependencies:
      nodejs:
        sass: '*'
```

2) Vite-built React app (static preview or serve behind a process)

```yaml
applications:
  frontend:
    type: nodejs:24

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        npm install --omit=dev
        npm run build

    web:
      # Option A: run a preview server (requires a script that accepts --port)
      commands:
        start: npm run serve -- --port=$PORT

      locations:
        /:
          root: dist
          index: [index.html]
          passthru: true

    dependencies:
      nodejs:
        sharp: '*'
```

Static caching rules (optional, under a location):

```yaml
web:
  locations:
    /:
      root: build
      rules:
        '\.(css|js|png|jpg|svg|webp)$':
          expires: 24h
```

pnpm / yarn setup

If your repo uses pnpm or yarn, install the package manager via dependencies so it's available in the build container. Update hooks accordingly.

pnpm example:

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

    web:
      commands:
        start: pnpm run serve -- --port=$PORT
      locations:
        /:
          root: dist
          index: [index.html]
```

Configuration checklist

- Confirm which package manager the project uses (check lockfiles).
- Ensure package.json has a `build` script that produces `build/` or `dist/` as appropriate.
- For static sites set `start: sleep infinity`; otherwise provide a start command that accepts $PORT.
- Add any build-time tool dependencies under dependencies.nodejs.

Reminder

Always verify runtime/service versions against the canonical registry before committing: https://meta.upsun.com/images
