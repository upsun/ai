## Jekyll Application Configuration

Jekyll is a Ruby-based static site generator that transforms markup content into production-ready websites.

### Build Process
- Run `bundle exec jekyll build` to generate the production site into the `_site/` directory (default).
- You can change the output directory with `--destination`, but this is uncommon.

### Production Deployment
- Do not use `jekyll serve` in production; it is a development server.
- Serve the generated `_site/` directory as static content only.

### Example application config
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
            "\.(css|js|gif|jpe?g|png|svg|webp)$":
              expires: 4w
```

### Configuration details
- Composable image: Uses nixpkgs for Ruby and Bundler packages via the composable runtime.
- Dependency management: `bundle install` installs gems from Gemfile/Gemfile.lock; ensure Gemfile.lock is committed for reproducible builds.
- Static site serving: The runtime uses a no-op process (`sleep infinity`) because the app serves static files from `_site/`.
- Caching strategy:
  - HTML content: 24-hour expiration.
  - Static assets (CSS/JS/images): 4-week expiration to improve performance.
- Security: Server-side scripts are disabled for static content (`scripts: false`).

### Usage notes & gotchas
- Ensure your build produces the `_site/` directory at the repository root. If your site source lives in a subdirectory, set a `source.root` entry in the application config pointing to that path.
- Always build via Bundler (`bundle exec`) to pick up the correct gem versions.
- If your site uses plugins that require native extensions, verify the required build toolchain is available in the composable environment.
