## Nuxt Application Configuration

Reference configuration for Nuxt.js applications on Upsun.

**Framework Priority**: Use Nuxt-specific configuration instead of generic Vite guidance when both apply.

**Minimum Requirements**: Node.js 20+

**Template Usage**: Adapt package manager commands and build configuration to project requirements. Exclude explanatory comments from production configurations.

```yaml
applications:
  app:
    # If your Nuxt app lives in a subdirectory, uncomment and set source.root
    # source:
    #   root: subdir/path

    type: nodejs:22

    dependencies:
      nodejs:
        pnpm: "*"

    build:
      flavor: none

    # Nuxt requires a writable .nuxt directory at runtime, and it also
    # prepopulates this directory at build time. Upsun mounts are writable
    # while the repository code is read-only at runtime. To avoid conflicts
    # we move the build .nuxt out of the way during build and repopulate
    # the mount during deploy.
    hooks:
      build: |
        set -ex
        pnpm install
        pnpm run build

        # Move build artifacts to a temporary location to avoid conflict with the later mount.
        mv .nuxt .nuxt-built

      deploy: |
        set -ex
        # Symlink/copy build artifacts (.nuxt-built) into the existing mount (.nuxt) during deployment.
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

## Configuration Details

- Package Manager: Adapt pnpm/npm/yarn based on project lockfile. npm, npx and bun can be used directly, but pnpm or yarn need to be installed in the dependencies as shown.
- Build Isolation: .nuxt directory is moved to .nuxt-built during build to prevent mount conflicts.
- Deployment Synchronization: Build artifacts are copied to the persistent mount during deploy; a build-tree-id file prevents redundant copies and coordinates multiple deploys.
- Pre-start Verification: The pre_start command waits for the deploy hook to finish before the server starts.
- Nitro Server: Uses Node.js server preset (NITRO_PRESET=node-server) for SSR capabilities.
- Static Assets: Serves from .output/public with 1-hour caching.
- Privacy: Nuxt telemetry disabled by default (NUXT_TELEMETRY_DISABLED=1).
- Directory Management: Nuxt build creates both .nuxt and .output. The .nuxt directory contains build artifacts for the mount; .output contains the server runtime and remains in place for the start command.

## Build Process Summary
1. Install dependencies and build the application (pnpm install && pnpm run build).
2. Move .nuxt to .nuxt-built to avoid conflicts with the runtime mount.
3. During deploy, copy/symlink .nuxt-built contents into the .nuxt mount and write PLATFORM_TREE_ID.
4. The web pre_start waits for the deploy marker to match before starting the server, preventing race conditions.
