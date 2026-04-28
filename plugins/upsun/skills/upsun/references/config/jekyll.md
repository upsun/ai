## Jekyll Application Configuration

Jekyll is a Ruby-based static site generator that transforms markup content into production-ready websites.

**Build Process**: 
- `jekyll build` generates production site in `_site/` directory (default)
- Custom output directory via `--destination` flag (uncommon)

**Production Deployment**:
- Avoid `jekyll serve` development server in production
- Serve `_site/` directory as static content only

**Template Usage**: Adapt caching policies to project requirements.

```yaml
applications:
  site:

    type: composable:25.11
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
            \.(css|js|gif|jpe?g|png|svg|webp)$:
              expires: 4w
```

**Configuration Details**:

- **Composable Image**: Uses nixpkgs for Ruby and bundler packages
- **Dependency Management**: Bundle installs gems from Gemfile.lock
- **Static Site Serving**: No-op process for static content delivery
- **Caching Strategy**:
  - HTML content: 24-hour expiration
  - Static assets (CSS/JS/images): 4-week expiration for performance
- **Security**: Server-side scripts disabled for static content

---

Version numbers change over time. Verify against https://meta.upsun.com/images before committing configuration.
