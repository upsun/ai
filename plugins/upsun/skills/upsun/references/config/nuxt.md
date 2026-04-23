## Nuxt Application Configuration

Reference configuration for Nuxt.js applications on Upsun.

**Framework Priority**: Use Nuxt-specific configuration instead of generic Vite guidance when both apply.

**Minimum Requirements**: Node.js 20+ required for Nuxt compatibility

**Template Usage**: Adapt package manager commands and build configuration to project requirements. Exclude explanatory comments from production configurations.

```yaml
applications:
  app:
    type: nodejs:24

    dependencies:
      nodejs:
        pnpm: "*"

    build:
      flavor: none

    # Nuxt requires a writable .nuxt directory at runtime, and it also prepopulates this directory at build time.
    # Upsun code is always read-only at runtime, and mounts are writable.
    # So we need to move some files around between the ".nuxt" directory created in the build and the ".nuxt" mount.
    #
    # This is a tested process that works well for Nuxt and should be used verbatim:
    #
    # 1. The build hook moves `.nuxt` to `.nuxt-built`, to prevent conflicts with the later mount.
    # 2. The deploy hook then symlinks the contents of `.nuxt-built` into the `.nuxt` mount.
    # 3. The `pre_start` command will wait for the deploy hook to finish before the server starts.
    hooks:
      build: |
        set -ex
        pnpm install
        pnpm run build

        # Move build artifacts to a temporary location to avoid conflict with the later mount.
        mv .nuxt .nuxt-built

      deploy: |
        set -ex
        # Symlink build artifacts (.nuxt-built) into the existing mount (.nuxt) during deployment.
        touch .nuxt/build-tree-id
        if [ "$(< .nuxt/build-tree-id)" != "$PLATFORM_TREE_ID" ]; then
          cp -Rs $PWD/.nuxt-built/* .nuxt
          echo -n "$PLATFORM_TREE_ID" > .nuxt/build-tree-id
        fi

    web:
      commands:
        pre_start: |
          # Wait for the deploy step to complete before starting the server.
          touch .nuxt/build-tree-id
          if [ "$(< .nuxt/build-tree-id)" != "$PLATFORM_TREE_ID" ]; then
            echo >&2 "Waiting for deployment to complete"
            while [ "$(< .nuxt/build-tree-id)" != "$PLATFORM_TREE_ID" ]; do sleep 1; done
          fi
        start: node .output/server/index.mjs

      locations:
        /:
          root: .output/public
          passthru: true
          expires: 1h
          scripts: false

    variables:
      env:
        NITRO_PRESET: node-server
        NUXT_TELEMETRY_DISABLED: '1'

    mounts:
      .nuxt:
        source: storage
```

Configuration Details:

- Package Manager: Adapt pnpm/npm/yarn based on project lockfile. `pnpm` or `yarn` must be added under `dependencies.nodejs` as shown; `npm` is available by default.
- Build Isolation: `.nuxt` directory is moved to `.nuxt-built` during build to avoid conflicts with the writable mount used at runtime.
- Deployment Synchronization: Build artifacts are copied into the persistent `.nuxt` mount during `deploy` to ensure runtime writes go to a writable location.
- Pre-start Verification: `pre_start` waits for the deploy hook to populate `.nuxt/build-tree-id` matching `PLATFORM_TREE_ID` before starting the server to avoid race conditions.
- Nitro Server: Uses Node.js server preset for SSR capabilities (`NITRO_PRESET: node-server`).
- Static Assets: Serves static files from `.output/public` with a 1-hour caching policy.
- Privacy: Nuxt telemetry disabled by default (`NUXT_TELEMETRY_DISABLED: '1'`).
- Directory Management: Nuxt build creates both `.nuxt` and `.output`. `.nuxt` is managed into a persistent mount; `.output` contains the runtime server and remains in place for the start command.
- Build Process:
  1. Install dependencies and build application
  2. Move build output to a temporary location
  3. Copy to persistent mount during deployment
  4. Synchronization prevents race conditions between build and runtime

Version note: This file uses the supported Node.js image nodejs:24. Always verify and prefer supported versions from the canonical registry before committing: https://meta.upsun.com/images
