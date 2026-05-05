## Next.js Application Configuration

Reference configuration for Next.js applications on Upsun.

**Minimum Requirements**: Next.js 15 requires Node.js 18.18+

**Adaptation Notes**: Modify package manager commands and build paths according to project structure.

```yaml
applications:
  app:

    type: nodejs:24

    dependencies:
      nodejs:
        pnpm: "*"

    build:
      flavor: none

    # Next.js requires a writable .next directory at runtime, and it also prepopulates this directory at build time.
    # Upsun code is always read-only at runtime, and mounts are writable.
    # So we need to move some files around between the ".next" directory created in the build and the ".next" mount.
    #
    # This is a tested process that works well for Next.js and should be used verbatim:
    #
    # 1. The build hook moves `.next` to `.next-built`, to prevent conflicts with the later mount.
    # 2. The deploy hook then symlinks the contents of `.next-built` into the `.next` mount.
    # 3. The `pre_start` command will wait for the deploy hook to finish before the server starts.
    hooks:
      build: |
        set -ex
        pnpm install
        pnpm run build

        # Move build artifacts to a temporary location to avoid conflict with the later mount.
        mv .next .next-built

      deploy: |
        set -ex
        # Symlink build artifacts (.next-built) into the existing mount (.next) during deployment.
        touch .next/build-tree-id
        if [ "$(< .next/build-tree-id)" != "$PLATFORM_TREE_ID" ]; then
          cp -Rs $PWD/.next-built/* .next
          echo -n "$PLATFORM_TREE_ID" > .next/build-tree-id
        fi

    web:
      commands:
        pre_start: |
          # Wait for the deploy step to complete before starting the server.
          touch .next/build-tree-id
          if [ "$(< .next/build-tree-id)" != "$PLATFORM_TREE_ID" ]; then
            echo >&2 "Waiting for deployment to complete"
            while [ "$(< .next/build-tree-id)" != "$PLATFORM_TREE_ID" ]; do sleep 1; done
          fi
        start: pnpm run start -p "$PORT"

      locations:
        /:
          root: public
          passthru: true
          expires: 1h
          scripts: false

    variables:
      env:
        NEXT_TELEMETRY_DISABLED: '1'

    mounts:
      .next:
        source: storage
```

**Key Configuration Elements**:

- **Package Manager**: Adapt pnpm/npm/yarn/bun based on project lockfile. `npm`, `npx` and `bun` can be used directly, but `pnpm` or `yarn` need to be installed in the `dependencies` as above.
- **Build Isolation**: `.next` directory moved during build to prevent mount conflicts
- **Deployment Sync**: Build artifacts copied to persistent mount during deployment
- **Pre-start Check**: Ensures latest build is available before server starts
- **Static Assets**: Public directory served with 1-hour caching
- **Privacy**: Next.js telemetry disabled by default
- **Port Binding**: Uses Upsun-provided PORT variable

**Build Process**:
1. Install dependencies and build application  
2. Move build output to temporary location
3. Copy to persistent mount during deployment
4. Synchronization prevents race conditions between build and runtime

---

Version numbers change over time. Verify against https://meta.upsun.com/images before committing configuration.
