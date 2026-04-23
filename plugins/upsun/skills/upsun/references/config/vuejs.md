## Vue.js Application Configuration

Vue.js is a progressive JavaScript framework for building user interfaces and single-page applications (SPAs). Modern Vue projects commonly use Vite to build a production-ready site into a `dist/` directory.

Key guidance
- Build with the project's build script (usually `npm run build`) and serve the generated `dist/` as static content.
- Do not run development servers in production; use `sleep infinity` when the app is purely static and served via web.locations.
- For Vue Router (history mode), ensure the router fallback is handled by serving `index.html` for unknown paths.

Example Upsun configuration (Vite / npm build -> static SPA):

```yaml
applications:
  app:
    type: nodejs:24

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        npm ci --omit=dev
        npm run build

    web:
      commands:
        start: sleep infinity

      locations:
        /:
          root: dist
          index: [index.html]
          scripts: false
          expires: 24h
          rules:
            '\.(css|js|gif|jpe?g|png|svg|webp)$':
              expires: 4w
```

Configuration details
- Node.js runtime: use nodejs:24 (select the latest supported Node.js image from the Registry).
- Build flavor: `none` — explicitly run the build in the `build` hook for deterministic behavior.
- Build hook: uses `npm ci --omit=dev` for reproducible installs and then runs the `build` script from package.json.
- Static serving: `web.locations./` serves the contents of `dist/`; `start: sleep infinity` is a no-op process appropriate for static-only apps.
- SPA routing: `index: [index.html]` ensures client-side routing falls back to the SPA entrypoint; configure router-base or router history as needed in your app.
- Caching strategy:
  - HTML (served from the location): expires: 24h
  - Static assets matching the rule: expires: 4w
- Security: `scripts: false` disables server-side script execution for static content.

Package manager guidance
- Match the project's package manager (detect lockfiles: `package-lock.json`, `pnpm-lock.yaml`, or `yarn.lock`).
- To enable pnpm or yarn on Upsun images, add them under `dependencies.nodejs:` so the build image installs them prior to the build step.

Minimal pnpm example:

```yaml
applications:
  app:
    type: nodejs:24
    build:
      flavor: none

    dependencies:
      nodejs:
        pnpm: "'*'"

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
          scripts: false
```

Notes and gotchas
- Ensure your package.json contains a `build` script that produces the `dist/` directory. The build hook will fail otherwise.
- If your project uses a custom output directory, update `web.locations./.root` accordingly.
- For server-side rendering (SSR) Vue apps, a different runtime/start command is required — this reference targets static SPA deployments.
- Avoid hard-coding secrets in example configs. Use Upsun variables or write a `.environment` file in the build hook when dynamic shell logic is required.

Verify image versions
- This reference uses nodejs:24 (supported). Always verify image types and versions at the canonical registry before committing: https://meta.upsun.com/images
