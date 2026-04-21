## React Application Configuration

React applications require a Node.js runtime configuration and appropriate build tooling so the build step produces static assets that Upsun can serve.

### Runtime

- Use Node.js runtime: nodejs:22

### Configuration approach

Apply standard Node.js patterns and the per-group Node guidance. Focus on:
- Build tool: Vite, Webpack, Create React App (CRA), or a custom build system.
- Package manager: npm or bun or npx are available by default. pnpm or yarn can be used but must be installed in the build step if not provided by the platform image.
- Static output: the final build directory is typically `build/` (CRA) or `dist/` (Vite/Webpack). Configure Upsun to serve that directory.

### Common build commands (examples)

- Create React App (CRA)

  - install: `npm ci`
  - build: `npm run build`  (produces `build/`)

- Vite (React)

  - install: `npm ci`
  - build: `npm run build`  (produces `dist/` by default)

- Webpack (custom)

  - install: `npm ci`
  - build: `npm run build`  (output dir depends on webpack config)

When using pnpm or yarn, substitute the install command accordingly (e.g. `pnpm install --frozen-lockfile`).

### Static serving

Ensure Upsun serves the build output directory (e.g. `build/` or `dist/`). If your app is a single-page app, configure the server to return `index.html` for unknown paths (SPA fallback).

### Package manager notes

- npx and bun are available by default in the build environment.
- If using pnpm or yarn, add an install step to the build process; ensure lockfile support for reproducible builds.

### Environment and runtime gotchas

- PUBLIC_URL / homepage: Many React setups (CRA, Vite) rely on a base/public path. Set the appropriate environment variable before build so asset URLs are correct.
- Node version mismatch: ensure local/dev Node matches nodejs:22 where possible.
- Asset paths: confirm the configured output directory and any path prefixes used by your framework.

### Workers / Databases / Options

React apps are front-end/static by nature. If your project includes server-side components (API workers, SSR), follow the Upsun language-group guidance for Node.js/SSR to configure workers, environment variables, and databases. This reference only covers client-side/static React builds.

### Quick checklist

- Set runtime to nodejs:22.
- Choose and document build tool (Vite/CRA/Webpack).
- Add reproducible install (npm ci / pnpm install --frozen-lockfile).
- Produce static assets into a known directory (`build/` or `dist/`).
- Configure static serving and SPA fallback if needed.
