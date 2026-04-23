## Jekyll Application Configuration

Jekyll is a Ruby-based static site generator that transforms markup content into production-ready websites.

### Build process
- Use `bundle exec jekyll build` to produce the production site in the `_site/` directory (default).
- A custom output directory can be specified with `--destination`, but this is uncommon.

### Production deployment
- Do not use `jekyll serve` in production. Build the site and serve the generated `_site/` directory as static files.

### Example Upsun configuration

```yaml
applications:
  site:
    type: composable:stable
    stack:
      packages:
        - ruby
        - bundler

    hooks:
      build: |
        set -ex
        # Ruby and bundler are available via nixpkgs in $PATH
        bundle install
        bundle exec jekyll build

    web:
      commands:
        start: sleep infinity

      locations:
        /:
          root: _site
          index: [index.html]
          scripts: false
          expires: 24h
          rules:
            '\.(css|js|gif|jpe?g|png|svg|webp)$':
              expires: 4w
```

Configuration notes

- Composable image: This example uses a composable image to give access to Nix packages (Ruby, bundler) at build time.
- Dependency management: Gems are installed from your Gemfile/Gemfile.lock via `bundle install` in the build hook.
- Static site serving: The app process is a no-op (`sleep infinity`) — Upsun serves the `_site/` directory as static files via the `web.locations` settings.
- Caching strategy:
  - HTML and other generated pages: 24-hour expiration (expires: 24h).
  - Static assets (CSS/JS/images): 4-week expiration (expires: 4w) to improve performance.
- Security: Server-side scripts are disabled for the static location (`scripts: false`).

Usage tips and gotchas

- Omit `source.root` unless your Jekyll source is not at the repository root. If your site lives in a subdirectory, add:
  source:
    root: path/to/site
- If your build needs additional tooling (Node.js-based asset builds, image processors, etc.), add those packages to `stack.packages` or include a runtime under `stack.runtimes`.
- Keep the `_site` directory out of source control and ensure your `.gitignore` excludes it.

Remember to verify images and service versions

- This reference uses a composable image (composable:stable) for build flexibility. When you select runtime or service images elsewhere, use only supported versions from the Upsun registry and prefer the highest supported version available for that runtime.
- Always confirm versions at the canonical registry URL before committing: https://meta.upsun.com/images
