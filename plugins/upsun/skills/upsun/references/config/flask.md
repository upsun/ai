## Flask Application Configuration

Reference configuration for Flask web applications on Upsun.

Server Options:
- Gunicorn (default): Standard WSGI server for Flask applications
- Uvicorn with Gunicorn: Use uvicorn worker class if uvicorn is in project dependencies

Template Usage: Customize configuration for project-specific requirements. Exclude explanatory comments from production configurations.

YAML example:

```yaml
applications:
  site:
    type: python:3.13

    dependencies:
      python3:
        uv: "*"

    hooks:
      build: |
        set -ex
        uv sync --frozen --no-dev --no-managed-python

        # Database URL setup for Flask-SQLAlchemy
        echo >> .environment 'export DATABASE_URL="$DB_SCHEME://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'

      deploy: |
        set -ex
        # uv run flask db upgrade

    web:
      commands:
        start: uv run gunicorn app:app --bind 0.0.0.0:$PORT

      locations:
        /:
          root: static
          passthru: true
          expires: 1h

    variables:
      env:
        FLASK_ENV: production

    relationships:
      db: {}

services:
  db:
    type: postgresql:16
```

Configuration Details:

- Python Version: Match project requirements from pyproject.toml or requirements.txt (example uses python:3.13).
- Package Manager: Adapt hooks to pip, poetry, or pipenv based on project setup.
- Database Integration: The example writes DATABASE_URL into .environment for Flask-SQLAlchemy compatibility.
- WSGI Application: Replace `app:app` in the start command to match your Flask application instance location.
- Server Selection:
  - Default: Gunicorn WSGI server.
  - Alternative: Add `--worker-class uvicorn.workers.UvicornWorker` to the gunicorn command if uvicorn is installed and you prefer ASGI workers.
- Static Files: Adjust `root` path to match your Flask static directory.
- Database Migrations: Uncomment the Flask-Migrate command in the deploy hook if using migrations.

Notes / Gotchas:
- Ensure project dependencies include any server (gunicorn, uvicorn) referenced in the start command.
- Keep runtime selection consistent with local development and CI to avoid surprises when deploying.
- The provided YAML is a minimal, working example—remove or adapt development-only commands for production.
