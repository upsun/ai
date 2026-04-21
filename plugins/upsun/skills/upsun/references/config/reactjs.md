## React Application Configuration

React applications require a Node.js runtime and a build step that produces a static asset directory (commonly `build/` or `dist/`). Configure Upsun using standard Node.js patterns and the framework-specific build commands below.

### Runtime

- Use Node.js 22: `nodejs:22` for the application runtime and build environment.

### Build tools & typical commands

Common build systems and their usual install/build commands:

- Vite
  - Install: `npm ci` or `pnpm install` / `bun install`
  - Build: `npm run build` (typically produces `dist/`)
- Create React App (CRA)
  - Install: `npm ci`
  - Build: `npm run build` (typically produces `build/`)
- Webpack (custom)
  - Install: `npm ci`
  - Build: `npm run build` (output directory depends on project config, often `dist/`)
- Custom scripts
  - Use whatever commands are defined in `package.json` (e.g. `npm run build:prod`).

Note: `npx` is available by default. `pnpm` and `yarn` may require installing in the build environment if not already provided.

### Package managers

- Supported: npm, bun, pnpm, yarn (when installed)
- Prefer reproducible installs: `npm ci` or `pnpm install --frozen-lockfile` where applicable.

### Static serving / Build output

- Identify the build output directory for static serving (commonly `build/` for CRA or `dist/` for Vite/webpack).
- Configure your static file server / Upsun static-route to point at that directory.

### Examples

- Vite (dist output)
  - Install: `npm ci`
  - Build: `npm run build` → output `dist/`
- Create React App (build output)
  - Install: `npm ci`
  - Build: `npm run build` → output `build/`
- Custom webpack
  - Install: `npm ci`
  - Build: `npm run build` → output as configured (often `dist/`)

### Gotchas

- Ensure environment variables required at build time are provided to the build step (e.g., feature flags or API base URLs used in the build).
- If you use server-side rendering or frameworks layered on React (Next.js, Remix), consult the specific framework reference instead of this static-react guidance.
- If you switch package manager (npm ↔ pnpm ↔ yarn), confirm lockfile and install command behavior in CI/build.

### Minimal Upsun config example

This minimal example shows the essential pieces Upsun needs: runtime, install step, build step, and where static files are produced. Adapt command names to your project.

runtime: nodejs:22
install:
  command: npm ci
build:
  command: npm run build
  output_dir: build

(Replace `output_dir` with `dist` if your project uses Vite/webpack producing `dist/`.)
