## Django Application Configuration

Reference configuration for Django web applications on Upsun.

**Framework Variants**: For Django derivatives (nanodjango, microdjango), adapt management commands accordingly.

**Template Usage**: Customize this configuration for project-specific requirements. Do not include explanatory comments in production configurations.

```yaml
applications:
  site:
    type: python:3.13

    dependencies:
      python3:
        uv: '*'

    hooks:
      build: |
        set -ex
        uv sync --frozen --no-dev --no-managed-python

        # Auto-detect WSGI module name
        export WSGI_NAME=$(basename "$(dirname "$(find . -maxdepth 4 -path './.*' -prune -o -name wsgi.py -print | head -n1)")")
        if [ -z "$WSGI_NAME" ]; then
          echo >&2 'Failed to find WSGI module name'
          exit 1
        fi

        # Configure Django settings for Upsun
        export settings_dir=$(basename "$(dirname "$(find . -maxdepth 4 -path './.*' -prune -o -name settings.py -print | head -n1)")")
        if [ -n "$settings_dir" ]; then
          echo >> "$settings_dir"/settings.py "\n# Upsun configuration"
          echo >> "$settings_dir"/settings.py 'ALLOWED_HOSTS = ["*"]'
          if ! grep -q STATIC_ROOT "$settings_dir"/settings.py; then
            echo >> "$settings_dir"/settings.py 'STATIC_ROOT = BASE_DIR / "static"'
            echo >> "$settings_dir"/settings.py 'STATIC_URL = "/static/"'
          fi
        fi

        uv run python manage.py collectstatic --noinput
        echo >> .environment "export WSGI_NAME=$WSGI_NAME"
        echo >> .environment 'export DATABASE_URL="$DB_SCHEME://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'

      deploy: |
        set -ex
        uv run python manage.py migrate --noinput

    web:
      commands:
        start: uv run gunicorn "$WSGI_NAME".wsgi:application --bind 0.0.0.0:$PORT

      locations:
        /:
          passthru: true
        /static:
          allow: true
          expires: 1h
          root: static
        /media:
          expires: 1h
          root: media
          scripts: false

    variables:
      env:
        UV_LINK_MODE: copy

    mounts:
      media:
        source: storage
      logs:
        source: storage

    relationships:
      db: {}

services:
  db:
    type: postgresql:16
```

**Configuration Details**:

- **Python Version**: Match project requirements from pyproject.toml or requirements.txt
- **Package Manager**: Adapt for pip, poetry, or pipenv based on project setup
- **WSGI Detection**: Automatically finds Django project structure
- **Static Configuration**: Auto-configures STATIC_ROOT and STATIC_URL if missing
- **Database Integration**: Sets up DATABASE_URL for django-environ or dj-database-url
- **File Handling**: 
  - `/static`: Cached static assets
  - `/media`: User uploads with storage mount
- **uv Optimization**: UV_LINK_MODE=copy prevents symlink issues in containers
