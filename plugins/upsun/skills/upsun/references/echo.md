## Echo Framework Configuration

Echo is a high-performance HTTP web framework for Go applications.

Usage note: keep production YAML free of inline commentary; examples below show minimal valid configurations.

### Minimal application (no special source root)

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

### If your app code lives in a subdirectory (source root)

```yaml
applications:
  app:
    source:
      root: api

    type: golang:1.25

    hooks:
      build: |
        set -ex
        cd api
        go build -o app .

    web:
      commands:
        start: ./app

    mounts:
      storage:
        source: storage
```

## Configuration details

- Runtime version: use golang:1.25 to match current supported Go runtime.
- Build process: prefer using an existing Makefile; otherwise use an explicit `go build -o <binary>` step as shown.
- Binary name: ensure the `web.commands.start` command matches the produced binary name.
- Many Echo examples use SQLite in development — if so, provide a writable mount for the DB file.

### Build configuration

With Makefile: detect production/static build target and binary name. Adjust the `hooks.build` to call `make <target>` and ensure `web.commands.start` runs that binary.

Without Makefile (explicit build):

```yaml
hooks:
  build: |
    set -ex
    go build -o app .
```

## Database options

SQLite (common for local/demo Echo apps):
- Detection: look for imports such as `github.com/mattn/go-sqlite3` or `gorm.io/driver/sqlite`.
- No DB service required; provide a writable mount and map the DB file location.

```yaml
mounts:
  storage:
    source: storage
```

Common DB file paths: `./app.db`, `./storage/app.db`, `./data/app.db` — map whichever your app uses to the `storage` mount.

PostgreSQL (production-ready deployments):
- Add a DB service and relationship.
- Populate a DATABASE_URL or equivalent in your build/runtime environment.

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

MySQL / MariaDB alternative:
- Use the appropriate DSN for the MySQL driver (e.g., go-sql-driver/mysql).

```yaml
hooks:
  build: |
    go build -o app .
    echo >> .environment 'export DSN="$DB_USERNAME:$DB_PASSWORD@($DB_HOST:$DB_PORT)/$DB_PATH"'

services:
  db:
    type: mariadb:11.4
```

## Gotchas

- Ensure the build output binary name and start command match exactly.
- If using CGO-based SQLite drivers (`github.com/mattn/go-sqlite3`), confirm that the build environment supports CGO or switch to a pure-Go driver or an external DB for production.
- Keep secrets out of committed YAML; rely on Upsun environment/relationships for DB credentials.
