## Jekyll Application Configuration

Jekyll is a Ruby-based static site generator that transforms markup content into a production-ready website.

Build process
- `jekyll build` generates the production site in the `_site/` directory (default).
- A custom output directory can be specified with `--destination` but is uncommon; Upsun expects the built site in a directory you configure as the web root.

Production deployment
- Do not run `jekyll serve` in production.
- Serve the built `_site/` directory as static content only (no runtime web server required).

Example Upsun application config (minimal, copy-pasteable):

```yaml
applications:
  site:
    type: ruby:4.0

    stack:
      packages:
        - bundler

    hooks:
      build: |
        set -ex
        # Ruby and bundler are available in the runtime image's PATH
        bundle install --deployment --without development test
        bundle exec jekyll build

    web:
      commands:
        start: sleep infinity

      locations:
        '/':
          root: _site
          index: [index.html]
          scripts: false
          expires: 24h
          rules:
            '\.(css|js|gif|jpe?g|png|svg|webp)$':
              expires: 4w
```

Configuration details and guidance

- Image choice: a Ruby runtime image (ruby:4.0) is appropriate for Jekyll sites. Alternatively, if you need access to many Nix packages or custom build tools, use a composable image and install ruby/bundler from nixpkgs during build.
- Dependencies: use Bundler (Gemfile/Gemfile.lock). The build hook runs `bundle install` before `jekyll build` so production gems are available.
- Static site serving: the app's start command should be `sleep infinity` for purely static sites; Upsun will serve files from the `web.locations` root.
- Caching strategy:
  - HTML content: 24h expiration (good default for frequent updates).
  - Static assets (CSS/JS/images): 4w expiration for performance.
- Security: server-side scripts are disabled (`scripts: false`) because the site is static.

Gotchas
- Ensure `_site` exists after the build (the `root` in the location must point to the built output).
- Do not embed secrets or production credentials directly in examples or hooks. Use Upsun variables or write a `.environment` in the build hook if you need to compute env vars.

Verify image versions
- Registry snapshots change over time. Before committing, verify the runtime/service image versions you use at the canonical registry: https://meta.upsun.com/images
