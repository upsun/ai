## Jekyll Application Configuration

Jekyll is a Ruby-based static site generator that transforms markup content into production-ready websites.

Build Process
- `jekyll build` generates the production site in the `_site/` directory by default.
- You can change the output with the `--destination` flag, though this is uncommon.

Production Deployment
- Do not use `jekyll serve` in production. Build the site and serve the generated `_site/` directory as static content.

Template usage note
- If your site lives in a subdirectory of the repo, add a `source:` block with `root: <path>` under the application (see example note below).

YAML example
```yaml
applications:
  site:
    type: composable:ruby:3.4
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
            \\\.(css|js|gif|jpe?g|png|svg|webp)$:
              expires: 4w
```

- If your repository's site sources are not at repository root, add e.g.:
```yaml
    source:
      root: docs/site
```
under the `site:` application.

Configuration details
- Composable image: Uses nixpkgs-provided Ruby and bundler packages.
- Dependency management: `bundle install` installs gems from Gemfile.lock.
- Static site serving: The app runs no-op process; Upsun serves the `_site/` directory as static content.
- Caching strategy:
  - HTML content: 24-hour expiration.
  - Static assets (CSS/JS/images): 4-week expiration for performance.
- Security: Server-side scripts are disabled for static content (scripts: false).

Gotchas
- Do not rely on `jekyll serve` for production; it is intended for development only.
- Ensure your Gemfile.lock is committed so the build produces deterministic gem versions.
