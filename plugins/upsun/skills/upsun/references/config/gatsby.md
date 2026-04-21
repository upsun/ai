## Gatsby Application Configuration

Reference configuration for Gatsby static-site applications on Upsun.

Gatsby is a React-based static site generator with optional SSR and dynamic data fetching. Use the example below as a base and adjust build scripts/commands to match your project's package.json.

```yaml
applications:
  site:
    type: nodejs:22

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        # Use `npm ci --omit=dev` for deterministic installs when package-lock.json is present and in sync.
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

    mounts:
      .cache/data:
        source: tmp
```

Configuration details

- Node.js Version: pinned to nodejs:22 (use the Registry's current supported runtime).
- Package installation: prefer `npm ci --omit=dev` for deterministic production installs when package-lock.json is present and accurate; the example uses `npm install --omit=dev` to avoid failures when lockfile and package.json disagree.
- Build: runs the project's Gatsby build script to produce the static `public/` output directory.
- Runtime server: uses a static server command (e.g., `gatsby serve` or a custom serve script) to serve the pre-built site. Ensure the command uses the Upsun-provided $PORT.
- Static files: served from `public/` directory produced by `gatsby build`.
- Cache: mount `.cache/data` to writable storage (tmp). Avoid mounting the entire `.cache` directory so build-time cache files remain intact.

Optional: repository subdirectory

If your Gatsby site is not at the repository root, add a source root entry under the application. Example:

```yaml
applications:
  site:
    source:
      root: website
    type: nodejs:22
    # ...rest as above
```

Gotchas

- Only mount the minimal runtime cache needed; mounting full `.cache` can break build-time caching behavior.
- Prefer deterministic installs in CI/CD (npm ci) but only when lockfile and package.json are kept in sync.
- Ensure your serve/start command binds to $PORT rather than a hardcoded port.
