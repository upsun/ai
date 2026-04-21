# Hugo Configuration Guide

Hugo is a static site generator, written in Go.

## Recommended: Using Hugo from Nix Packages

The composable image includes Hugo in its package catalog, providing easy access with full support for Hugo modules:

```yaml
applications:
  app:
    type: composable:stable
    stack:
      packages:
        - hugo  # Uses the stable channel from nixpkgs
        - go    # Required for Hugo modules and theme dependencies
        # Or for the latest version:
        # - package: hugo
        #   channel: unstable
    hooks:
      build: |
        set -ex
        hugo --destination=public
    web:
      commands:
        start: sleep infinity # Used for static sites.
      locations:
        /:
          root: public
          index:
            - index.html
          expires: 1h
          scripts: false
```

Benefits:
- Simpler configuration
- Automatic git and SSL certificate support for Hugo modules
- Go included for theme dependencies and Hugo modules
- No manual version management needed

## Alternative: Pinning a Specific Hugo Version

If you need a specific Hugo version not yet available in Nix packages, use the Upsun-provided script to download the Hugo binary:

```yaml
applications:
  app:
    type: composable:stable
    stack: {}
    hooks:
      build: |
        set -ex

        # The install-github-asset script handles downloading a binary and extracting it to the correct location, including caching.
        curl -sfSL https://raw.githubusercontent.com/upsun/config-assets/main/scripts/install-github-asset.sh \
        | bash -s -- gohugoio/hugo v0.150.0 hugo_extended_0.150.0_linux-amd64.tar.gz

        # Run the build.
        hugo --destination=public
    web:
      commands:
        start: sleep infinity # Used for static sites.
      locations:
        /:
          root: public
          index:
            - index.html
          expires: 1h
          scripts: false
```

When to use this approach:
- You need a very specific Hugo version
- You want to control the exact Hugo release independently of Nix package updates

Usage notes / gotchas:
- If your project uses Hugo modules or themes that require Go, prefer the Nix package approach so Go is available during the build.
- For projects where your source is not at the repository root, set the application source.root in the application definition to the correct path.
- The `start: sleep infinity` command is intentional for static sites — the web server serves files from the `public` directory via the configured location block.
