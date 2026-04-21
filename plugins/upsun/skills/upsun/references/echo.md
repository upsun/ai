## Echo Framework Configuration

Echo is a high-performance HTTP web framework for Go applications.

Template usage: provide a minimal, production-ready Upsun application config for Echo apps.

```yaml
applications:
  app:
    type: golang:1.25

    hooks:
      build: |
        set -ex
        go build -o app .

    web:
      commands:
        start: ./app

      locations:
        /:
          passthru: true

    mounts:
      storage:
        source: storage
```

If your application lives in a subdirectory of the repository, add a source root block:

```yaml
applications:
  app:
    source:
      root: backend
    type: golang:1.25
    # ...rest as above
```

Configuration details

- Runtime version: use the exact Go runtime from the Registry that matches your app requirements (example: golang:1.25).
- Build process: prefer a Makefile when present. Otherwise use an explicit `go build -o <binary>` to produce a deterministic binary name.
- Binary name: ensure the web start command matches the binary produced by the build step.
- Database: many Echo apps use SQLite for development; SQLite requires a writable storage mount for the DB file.

Build configuration

With Makefile
- Inspect the Makefile to determine the production build target and resulting binary name.
- Match the `hooks.build` content and `web.commands.start` to the Makefile target/output.

Without Makefile (explicit):

```yaml
hooks:
  build: |
    set -ex
    go build -o app .
```

Database options

SQLite (common for Echo apps)
- Detection: look for imports such as `github.com/mattn/go-sqlite3` or `gorm.io/driver/sqlite`.
- No external DB service required; map a writable mount to the DB file path.
- Common DB paths: `./app.db`, `./storage/app.db`, `./data/app.db`.

```yaml
mounts:
  storage:
    source: storage
```

PostgreSQL (production)
- Add a DB service and relationship.
- Set DATABASE_URL into the build or runtime environment so the app picks it up.

```yaml
hooks:
  build: |
    go build -o app .
    echo >> .environment 'export DATABASE_URL="postgres://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'

relationships:
  db: {}

services:
  db:
    type: postgresql:16
```

MySQL / MariaDB alternative
- Use the appropriate DSN format for drivers such as `go-sql-driver/mysql`.

```yaml
hooks:
  build: |
    go build -o app .
    echo >> .environment 'export DSN="$DB_USERNAME:$DB_PASSWORD@($DB_HOST:$DB_PORT)/$DB_PATH"'

services:
  db:
    type: mariadb:11.4
```

Notes and gotchas

- Ensure any Cgo dependencies (e.g., `github.com/mattn/go-sqlite3`) are supported in the build environment; add necessary build tags or toolchain requirements.
- Keep the start command in `web.commands.start` consistent with the produced binary name and any required flags or env vars.
- Avoid embedding explanatory comments in production YAML; keep runtime configuration explicit and minimal.
