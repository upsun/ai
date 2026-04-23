## Gatsby Application Configuration

Reference configuration for Gatsby static site applications on Upsun.

**Framework Overview**: React-based static site generator with SSR support and dynamic data fetching capabilities.

**When to set source.root**: If the Gatsby site lives in a subdirectory of the repository, add a `source:` block with `root: <path>` under the application; omit it when the app is at the repo root.

```yaml
applications:
  site:
    type: nodejs:24

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        # This could use 'npm ci' (deterministic) but only when package.json and package-lock.json are in sync.
        npm install --omit=dev
        npm run build

    web:
      commands:
        start: npm run serve -- --port=$PORT

      locations:
        '/':
          root: public
          passthru: true
          index: [index.html]

    mounts:
      .cache/data:
        source: tmp
```

Configuration Details:

- Node.js Version: examples use `nodejs:24` (the highest supported Node.js runtime in the registry snapshot). Verify available versions at the canonical registry before committing.
- Package installation: the example build hook uses `npm install --omit=dev`. For deterministic production installs prefer `npm ci --omit=dev` when a matching package-lock.json is present.
- Build process: runs Gatsby's build script to generate static output into the `public/` directory.
- Runtime server: runs the `serve` script (commonly `gatsby serve`) to serve the pre-built files; the start command must respect the Upsun-provided `$PORT` environment variable.
- Static files: served from the `public/` directory produced by `npm run build`.
- Cache management: mount `.cache/data` to `tmp` to provide writable runtime cache without mounting the whole `.cache` directory (preserves build-time cache artifacts).
- Port configuration: respect `$PORT` for the HTTP server.

Usage notes and gotchas:

- If your project uses a monorepo or the Gatsby app is not at repository root, add:

```yaml
    source:
      root: path/to/site
```

under `applications.site`.

- Ensure `index: [index.html]` is only present when `public/index.html` will exist after build; otherwise omit the `index` line.

- If your project requires additional native build tools (e.g. sharp), add them under `dependencies.nodejs` so the build container installs them prior to the build.

Verify image versions

- Images in this document use versions from the Upsun image registry snapshot. Always verify the exact runtime and service versions at: https://meta.upsun.com/images before committing, because versions are deprecated or retired over time.
