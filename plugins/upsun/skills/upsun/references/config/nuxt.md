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

**Configuration Details**:

- **Package Manager**: Adapt pnpm/npm/yarn based on project lockfile. `npm`, `npx` and `bun` can be used directly, but `pnpm` or `yarn` need to be installed in the `dependencies` as above.
- **Build Isolation**: `.nuxt` directory managed during build to prevent mount conflicts
- **Deployment Synchronization**: Build artifacts copied to persistent mount during deployment
- **Pre-start Verification**: Ensures latest build is available before server starts
- **Nitro Server**: Uses Node.js server preset for SSR capabilities
- **Static Assets**: Serves from `.output/public` with 1-hour caching
- **Privacy**: Nuxt telemetry disabled by default
- **Directory Management**: Nuxt build creates both `.nuxt` and `.output` directories. The `.nuxt` directory contains build artifacts for mounting, while `.output` contains the server runtime and should remain in place for the start command.
- **Build Process**:
  1. Install dependencies and build application
  2. Move build output to temporary location
  3. Copy to persistent mount during deployment
  4. Synchronization prevents race conditions between build and runtime

---

Version numbers change over time. Verify against https://meta.upsun.com/images before committing configuration.
