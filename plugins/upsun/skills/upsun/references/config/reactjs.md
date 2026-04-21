## React Application Configuration

React applications require a Node.js runtime and explicit build tooling configuration so the platform can build and serve the generated static assets.

Key points
- Runtime: use nodejs:22 for React builds.
- Build tools: Vite, Webpack, Create React App (CRA), or custom build systems are all supported; specify the project-specific build commands.
- Package managers: npm and bun are available by default. pnpm or yarn can be used but must be installed/activated during the build step if not present.
- Static serving: set the build output directory (commonly `dist/` for Vite or `build/` for CRA) and ensure a fallback (usually `index.html`) for client-side routing.

Reference
Apply the Node.js per-group guidance (runtime, memory, environment) and supply framework-specific build commands and static file serving configuration.

Example: Vite (npm)
```yaml
service:
  name: web
  runtime: nodejs:22
  build:
    commands:
      - npm ci
      - npm run build
  static:
    path: dist
    fallback: index.html
```

Example: Create React App (pnpm)
```yaml
service:
  name: web
  runtime: nodejs:22
  build:
    commands:
      - corepack enable
      - corepack prepare pnpm@latest --activate
      - pnpm install
      - pnpm run build
  static:
    path: build
    fallback: index.html
```

Usage notes
- Ensure the build command produces a single directory with static assets. Configure that directory as the `static.path` for serving.
- For single-page apps, set `fallback: index.html` so client-side routing works.
- If using environment-based base paths (e.g., `PUBLIC_URL`, `homepage` or Vite's `base`), set those env vars at build time so assets reference correct URLs.
- If using pnpm or yarn, install/activate them in the build step (Corepack is a recommended approach).

Gotchas
- Forgetting to set the correct output directory (e.g., `dist` vs `build`) will result in no static files being served.
- Not enabling a fallback page breaks client-side navigation (404s on refresh).
- If you use server-side rendering or frameworks that are not pure SPA (e.g., Next.js), follow the framework-specific reference instead of this SPA guidance.

Database / Workers / Options
- React frontends are typically static assets; any databases or background workers belong to backend services and should be configured separately.
- For edge functions or serverless APIs that accompany a React app, ensure their runtimes and routes are declared in the appropriate service entries, not in the static frontend config.
