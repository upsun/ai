## Jekyll Application Configuration

Jekyll is a Ruby-based static site generator that transforms markup content into production-ready websites.

**Build Process**:
- `jekyll build` generates the production site in the `_site/` directory (default)
- Custom output directory via `--destination` flag (uncommon)

**Production Deployment**:
- Avoid `jekyll serve` development server in production
- Serve `_site/` directory as static content only

**Template Usage**: Adapt caching policies to project requirements.

```yaml
applications:
  site:
    type: "composable:ruby:3.4"
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
            "\\.(css|js|gif|jpe?g|png|svg|webp)$":
              expires: 4w
```

### Configuration Details

- **Composable Image**: Uses nixpkgs for Ruby and bundler packages
- **Dependency Management**: `bundle install` installs gems from Gemfile.lock
- **Static Site Serving**: No-op process for static content delivery (`sleep infinity`) — the platform serves files from `_site`
- **Caching Strategy**:
  - HTML content: 24-hour expiration
  - Static assets (CSS/JS/images): 4‑week expiration for performance
- **Security**: Server-side scripts disabled for static content (`scripts: false`)

### Usage notes & gotchas

- Ensure your Gemfile.lock is committed so builds are reproducible.
- If your site uses plugins that require native extensions, confirm the composable image provides necessary build tools or add them to `stack.packages`.
- If your source files are in a subdirectory, add a `source.root` entry pointing to that path in the application config.
- If you need a custom `jekyll build` command (e.g., baseurl or destination flags), modify the `hooks.build` script accordingly.

### Database / worker / options

- Jekyll sites are static — typically no database or background workers required. If you build dynamic assets during build (e.g., search index generation), run those steps in `hooks.build`.
