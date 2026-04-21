## Nuxt Application Configuration

Reference configuration for Nuxt.js applications on Upsun.

Framework Priority: Use Nuxt-specific configuration instead of generic Vite guidance when both apply.

Minimum Requirements: Node.js 20+ required for Nuxt compatibility. This example uses the supported runtime nodejs:22.

Template Usage: Adapt package manager commands and build configuration to project requirements. Exclude explanatory comments from production configurations; the YAML below includes concise, actionable notes.

```yaml
applications:
  app:
    type: nodejs:22

    dependencies:
      nodejs:
        pnpm: "*"

    build:
      flavor: none

    # Nuxt requires a writable .nuxt directory at runtime, and it also prepopulates this directory at build time.
    # Upsun code is always read-only at runtime, and mounts are writable.
    # The process below moves build output to a temporary location and then syncs it into the writable mount.
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

Configuration Details:

- Package Manager: Use pnpm (installed via dependencies) if your project requires it; adapt to npm/yarn/bun if needed.
- Build Isolation: The .nuxt directory is moved to .nuxt-built during build to avoid conflicts with the writable mount at runtime.
- Deployment Synchronization: Build artifacts are copied into the persistent .nuxt mount during deploy; a build-tree-id file prevents redundant copies and avoids race conditions.
- Pre-start Verification: The pre_start step waits for the deploy hook to place the correct build artifacts before the server begins.
- Nitro Server: Uses the Node.js server preset (NITRO_PRESET=node-server) for SSR.
- Static Assets: Served from .output/public with 1-hour caching.
- Privacy: Nuxt telemetry disabled by default (NUXT_TELEMETRY_DISABLED=1).
- Directory Management: Nuxt creates both .nuxt (build artifacts for mounting) and .output (runtime). Keep .output in place for the start command; sync .nuxt into the mount as shown.

Build Process Summary:
1. Install dependencies and build application (pnpm install && pnpm run build).
2. Move .nuxt to .nuxt-built to avoid mount conflicts.
3. During deploy, copy .nuxt-built into the persistent .nuxt mount if the build tree id differs.
4. pre_start waits for the deploy step's tree id before starting the server to avoid races.
