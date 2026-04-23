## Nuxt Application Configuration

Reference configuration for Nuxt.js applications on Upsun.

**Framework Priority**: Use Nuxt-specific configuration instead of generic Vite guidance when both apply.

**Minimum Requirements**: Node.js 20+ required for Nuxt compatibility. This reference uses the currently supported runtime image below.

```yaml
applications:
  app:
    # Optional: set if your Nuxt source is not at the repository root
    # source:
    #   root: src

    type: nodejs:24

    dependencies:
      nodejs:
        pnpm: '*'

    build:
      flavor: none

    # Nuxt requires a writable .nuxt directory at runtime, and it also prepopulates this directory at build time.
    # Upsun code is always read-only at runtime, and mounts are writable.
    # So we need to move some files around between the ".nuxt" directory created in the build and the ".nuxt" mount.
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

- Package Manager: Adapt pnpm/npm/yarn based on project lockfile. pnpm is shown above and must be listed under dependencies to be available at build time.
- Build Isolation: `.nuxt` directory is moved to `.nuxt-built` at build time to avoid conflicts with the runtime mount.
- Deployment Synchronization: Build artifacts are copied into the persistent `.nuxt` mount during the deploy hook.
- Pre-start Verification: The `pre_start` command waits until the deploy hook has populated `.nuxt` with the current PLATFORM_TREE_ID before starting the server.
- Nitro Server: Uses Node.js server preset (NITRO_PRESET=node-server) for SSR capabilities.
- Static Assets: Serves from `.output/public` with 1-hour caching and passthru enabled for SSR fallthrough.
- Privacy: Nuxt telemetry disabled by default (NUXT_TELEMETRY_DISABLED=1).
- Directory Management: Nuxt build creates both `.nuxt` and `.output`. `.nuxt` contains build artifacts for mounting, while `.output` contains the server runtime used by the start command.

Build Process Summary:
1. Install dependencies and build application in the build hook.
2. Move `.nuxt` to `.nuxt-built` to avoid mount conflicts.
3. Copy `.nuxt-built` into the persistent `.nuxt` mount during deploy.
4. `pre_start` ensures the runtime waits for deploy synchronization to avoid race conditions.

Note: This example uses the supported Node.js runtime image `nodejs:24`. Always verify available and supported runtime and service versions against the canonical registry before committing, at: https://meta.upsun.com/images
