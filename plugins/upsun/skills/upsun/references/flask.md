## Flask Application Configuration

Reference configuration for Flask web applications on Upsun.

Server Options:
- Gunicorn (default): Standard WSGI server for Flask applications
- Uvicorn with Gunicorn: Use uvicorn worker class if uvicorn is in project dependencies

Template example (minimal, ready-to-use):

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

- Python Version: Match project requirements from pyproject.toml or requirements.txt; example uses python:3.13.
- Package Manager: Adapt for pip, poetry, or pipenv based on project setup. The hooks shown assume Upsun's uv sync step for dependency installation.
- Database Integration: DATABASE_URL environment variable is set for Flask-SQLAlchemy compatibility. Adjust the DB_SCHEME and path as needed for your adapter.
- WSGI Application: Modify `app:app` to match your Flask application instance location (module:app).
- Server Selection:
  - Default: Gunicorn WSGI server as shown.
  - Alternative: If using Uvicorn workers, add `--worker-class uvicorn.workers.UvicornWorker` to the gunicorn command and ensure `uvicorn` is installed.
- Static Files: Adjust `root` path to match your Flask static directory.
- Database Migrations: Uncomment and use `uv run flask db upgrade` in the deploy hook if using Flask-Migrate.

Usage notes / Gotchas:
- Remove or adapt explanatory comments in production configuration files.
- Ensure the `DATABASE_URL` formation matches how your app reads DB credentials (some apps expect `SQLALCHEMY_DATABASE_URI`).
- Confirm the `start` command runs in the correct working directory and that the Python path resolves your application module.
- If your project has a non-root source layout, add a `source.root:` entry under the application with the repository path to the app sources.
