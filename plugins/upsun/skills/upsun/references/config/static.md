# Static Sites Guide

A purely static site can be hosted on Upsun. For static sites, **composable images are recommended** as they provide flexibility in choosing build tools and dependencies without being constrained by a specific runtime.

## Recommended: Composable Image Approach

Use composable images when you need specific build tools or have custom requirements:

```yaml
applications:
  app:
    type: composable:stable

    stack:
      runtimes:
        - nodejs@24  # Or any runtime needed for build tools
      packages:
        - hugo  # Example: add any additional build tools from Nix packages

    hooks:
      build: |
        set -ex
        npm run build

    web:
      commands:
        start: sleep infinity # Used for static sites.

      locations: # Configure Upsun to serve the static files.
        '/':
          root: public # The directory containing the static files, relative to the application root.
          index:
            - index.html
          expires: 1h
          scripts: false
```

**Benefits of composable images for static sites**:
- Access to 120,000+ Nix packages for build tools
- Mix multiple build tools (e.g., Node.js + Python + Go) in one container
- Use the latest versions of tools without waiting for runtime image updates
- Simpler configuration when you only need build-time dependencies

## Alternative: Standard Runtime Images

If the site uses a common build tool available in standard runtimes, you can use a regular runtime image:

```yaml
applications:
  app:
    type: nodejs:24

    hooks:
      build: |
        set -ex
        npm run build

    web:
      commands:
        start: sleep infinity

      locations:
        '/':
          root: public
          index:
            - index.html
          expires: 1h
          scripts: false
```

**When to use standard runtime images**:
- The site uses only npm/Node.js for building
- You don't need packages beyond what's in the standard runtime
- You prefer the simplicity of a preconfigured environment

This is a generic static site example. If given more specific guidance for a particular framework, then defer to that.

---

Note: verify the image/service versions used above against the canonical Upsun registry before committing, as versions are deprecated or retired over time: https://meta.upsun.com/images
