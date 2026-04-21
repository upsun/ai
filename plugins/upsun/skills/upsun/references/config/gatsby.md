## Gatsby Application Configuration

Reference configuration for Gatsby static-site applications on Upsun.

Framework overview

- React-based static site generator with SSR support and dynamic data fetching capabilities.

Template usage

- Adapt configuration to project-specific build tools and deployment requirements.
- Do not include explanatory comments in production configurations.

YAML example — minimal

```yaml
applications:
  site:
    type: nodejs:22

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        # Use a production install and build the static site
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
      ".cache/data":
        source: tmp
```

Optional: repository subdirectory (source root)

If your Gatsby app is in a subdirectory, add a source root. Example when the app is under `frontend/`:

```yaml
applications:
  site:
    source:
      root: frontend
    type: nodejs:22
    # ...rest follows as above
```

Configuration details

- Node.js version: nodejs:22 (use latest supported runtime from the Registry).
- Package installation: use `npm ci` for deterministic installs when you have a package-lock.json; otherwise `npm install --omit=dev` is safe for production builds.
- Build process: runs Gatsby build script to generate static assets into the `public/` directory.
- Runtime server: `gatsby serve` (or your custom serve script) serves the pre-built static files.
- Static files: served from the `public/` directory produced by `gatsby build`.
- Cache management:
  - Mount `.cache/data` to `tmp` to provide writable runtime cache storage.
  - Avoid mounting the entire `.cache` directory; preserve build-time cache files that speed builds.
- Port configuration: Upsun provides the PORT environment variable; ensure your start command uses it.

Gotchas

- Prefer `npm ci --omit=dev` for reproducible production builds when package-lock.json is present.
- If using Yarn or pnpm, replace npm commands accordingly and ensure the lockfile is committed.
- If your build requires environment variables (API keys, tokens), set them via Upsun project/secret configuration, not in the repo.
