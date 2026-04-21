## React Application Configuration

React applications require a Node.js runtime and standard build tooling. Configure Upsun to run the project install + build steps and serve the static build output.

Runtime
- Use the Node.js runtime: nodejs:22

Package managers
- npm (default)
- npx (available by default)
- bun (available depending on image/runtime)
- pnpm (can be used if your image provides it or install in the build step)
- yarn (requires installing in build step or image)

Common build toolchains
- Vite: modern, outputs to `dist/` by default; set base if deploying to a subpath
- Create React App (CRA): outputs to `build/` by default; set `homepage` or `PUBLIC_URL` for non-root paths
- Webpack / custom: output dir often `dist/` or `build/`

Key gotchas
- Ensure the build output directory configured in Upsun matches your tool's output (`build/` or `dist/`).
- For client-side routing (React Router), configure a SPA fallback to `index.html` so deep links resolve to your app.
- Set proper base/public path:
  - Vite: set `base` in `vite.config.js` or use `--base` build flag
  - CRA: set `homepage` in package.json or `PUBLIC_URL` env var
- Build must run with NODE_ENV=production to produce optimized assets.
- Cache node_modules between builds if supported by the platform to speed builds.

Minimal configuration examples
- Vite (build output: dist/):

YAML example (Vite):
runtime:
  node: "22"
build:
  install_command: "npm ci"
  build_command: "npm run build"
  output_dir: "dist"
static:
  directory: "dist"
  spa_fallback: "index.html"

- Create React App (build output: build/):

YAML example (CRA):
runtime:
  node: "22"
build:
  install_command: "pnpm install"
  build_command: "pnpm run build"
  output_dir: "build"
static:
  directory: "build"
  spa_fallback: "index.html"

Notes on package manager commands
- npm: install with `npm ci` (preferred for CI) or `npm install`
- pnpm: install with `pnpm install` (pnpm must be available in the runtime or installed in install_command)
- yarn: install with `yarn install` (install yarn if image lacks it)

Environment and runtime tips
- Expose only the static build; server-side Node process is usually not needed for a SPA unless you run an SSR setup.
- For SSR or Node-based servers, adapt the build step to produce server bundles and configure a Node process to run in runtime: nodejs:22.

When to change defaults
- If your project uses a nonstandard output dir, update `output_dir` accordingly.
- If you need additional install steps (postinstall scripts, binary tools), add them to `install_command`.

Reference
- Apply standard Node.js runtime guidance and replace the build/install commands and output directory with the values required by your chosen React toolchain.
