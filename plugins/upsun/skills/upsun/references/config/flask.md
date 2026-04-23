## Flask Application Configuration

Reference configuration for Flask web applications on Upsun.

**Server Options**:
- **Gunicorn** (default): Standard WSGI server for Flask applications
- **Uvicorn** with Gunicorn: Use uvicorn worker class if uvicorn is in project dependencies

**Template Usage**: Customize configuration for project-specific requirements. Exclude explanatory comments from production configurations.

```yaml
applications:
  site:
    type: python:3.14

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
        '/':
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
    type: postgresql:18
```

**Configuration Details**:

- **Python Version**: Match project requirements from pyproject.toml or requirements.txt
- **Package Manager**: Adapt for pip, poetry, or pipenv based on project setup (this example uses uv)
- **Database Integration**: DATABASE_URL environment variable for Flask-SQLAlchemy compatibility
- **WSGI Application**: Modify `app:app` to match Flask application instance location
- **Server Selection**:
  - Default: Gunicorn WSGI server
  - Alternative: Add `--worker-class uvicorn.workers.UvicornWorker` to the Gunicorn command if uvicorn is installed
- **Static Files**: Adjust `root` path to match Flask static directory
- **Database Migrations**: Uncomment the Flask-Migrate command in the deploy hook if using database migrations

Notes and gotchas:
- Use the appropriate dependency manager stanza (uv / poetry / pipenv / pip) for your project; this example uses uv and `uv sync` / `uv run` helpers.
- Ensure the `relationships.db` entry corresponds to the `services.db` service so the $DB_* variables are available during the build and deploy hooks.

Verify image/service versions

- Images and service versions in this file were selected from the Upsun registry snapshot. Always verify current supported versions at: https://meta.upsun.com/images before committing, since versions are deprecated or retired over time.
