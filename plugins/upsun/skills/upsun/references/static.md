Static Sites Guide

A purely static site can be hosted on Upsun. For static sites, composable images are recommended because they provide flexibility in choosing build tools and dependencies without being constrained by a specific runtime.

## Recommended: Composable Image Approach

Use composable images when you need specific build tools or have custom requirements. If your application source is not at the repository root, add a source.root entry pointing to the path within the repo.

Example (minimal, valid):

applications:
  app:
    type: composable:stable

    stack:
      runtimes:
        - nodejs@22  # Add any runtimes required for build tools
      packages:
        - hugo       # Example: include Nix packages for build tooling

    hooks:
      build: |
        set -ex
        npm run build

    web:
      commands:
        start: sleep infinity # Static sites do not run a server process

      locations:
        /:
          root: public # Directory with generated static files, relative to app root
          index:
            - index.html
          expires: 1h
          scripts: false

Benefits of composable images for static sites:
- Access to 120,000+ Nix packages for build tools
- Mix multiple build tools (e.g., Node.js + Python + Go) in one container
- Use the latest versions of tools without waiting for runtime image updates
- Simpler configuration when you only need build-time dependencies

## Alternative: Standard Runtime Images

If the site uses a common build tool available in standard runtimes, you can use a regular runtime image. Use this when your build only needs the runtime's preinstalled tools (for example, a typical Node.js build).

Example:

applications:
  app:
    type: nodejs:22

    hooks:
      build: |
        set -ex
        npm run build

    web:
      commands:
        start: sleep infinity

      locations:
        /:
          root: public
          index:
            - index.html
          expires: 1h
          scripts: false

When to use standard runtime images:
- The site uses only npm/Node.js for building
- You don't need packages beyond what's in the standard runtime
- You prefer the simplicity of a preconfigured environment

## Notes and Gotchas
- For static sites, the web.start command commonly uses a no-op like sleep infinity because Upsun serves files from the configured location; there is no long-running app process.
- Ensure the build hook emits the static files to the directory configured under locations./.root (commonly public or dist).
- If your repo layout places the site in a subdirectory, add a source.root entry pointing to that path under the application config.

This is a generic static site example. If you have framework-specific guidance (Hugo, Jekyll, Eleventy, Next.js static export, etc.), prefer the framework-specific reference when available.
