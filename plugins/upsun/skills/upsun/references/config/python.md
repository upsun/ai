## Python Application Configuration

Reference configurations for Python applications using different dependency managers.

Selection Guide: Choose configuration based on project's dependency management:
- uv: Modern, fast Python package manager (uv.lock file)
- Poetry: Popular dependency manager (poetry.lock file)
- Pipenv: Environment manager (Pipfile/Pipfile.lock)
- pip: Standard package installer (requirements.txt)

### uv Package Manager

Detection: uv.lock file presence

```yaml
applications:
  example:
    source:
      root: /backend # The source of this application, as a file path within the repository.

    type: python:3.14

    dependencies:
      python3:
        uv: '*'

    hooks:
      build: |
        set -ex
        uv sync --frozen --no-dev --no-managed-python

      deploy: |
        uv run python manage.py collectstatic --noinput

    web:
      commands:
        start: uv run python app.py
```

Key Features:
- `--frozen`: Use exact versions from lock file
- `--no-dev`: Exclude development dependencies
- `--no-managed-python`: Use system Python version
- `uv run`: Execute commands within uv environment

### Poetry Package Manager

Detection: poetry.lock file presence

```yaml
applications:
  example:
    type: python:3.14

    dependencies:
      python3:
        poetry: '*'

    hooks:
      build: |
        set -ex
        poetry config virtualenvs.create false
        export PIP_USER=0
        poetry install --only=main

      deploy: |
        poetry run python manage.py collectstatic --noinput

    web:
      commands:
        start: poetry run python app.py
```

Configuration Notes:
- `virtualenvs.create false`: Disable Poetry's virtual environment (Upsun handles isolation)
- `--only=main`: Install production dependencies only
- `poetry run`: Execute commands within Poetry environment

### Pipenv Package Manager

Detection: Pipfile and Pipfile.lock files

```yaml
applications:
  example:
    type: python:3.14

    dependencies:
      python3:
        pipenv: '*'

    hooks:
      build: |
        set -ex
        export PIP_USER=0
        pipenv sync --system

    web:
      commands:
        start: pipenv run python app.py
```

Key Options:
- `--system`: Install to system Python rather than virtual environment
- `pipenv run`: Execute within Pipenv environment

### pip Package Manager

Detection: requirements.txt file

```yaml
applications:
  example:
    type: python:3.14

    hooks:
      build: |
        set -ex
        pip install -r requirements.txt

    web:
      commands:
        start: python app.py
```

### Database Configuration

Database Connection Setup: Add to build hook for applications requiring database access:

```bash
# Add to build hook
echo >> .environment 'export DATABASE_URL="$DB_SCHEME://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'
```

Usage: Works with Django, Flask, SQLAlchemy and other frameworks that accept DATABASE_URL environment variable.

---

Note: This reference uses python:3.14 (the highest supported Python runtime in the provided registry snapshot). Always verify runtime and service versions against the canonical registry before committing: https://meta.upsun.com/images
