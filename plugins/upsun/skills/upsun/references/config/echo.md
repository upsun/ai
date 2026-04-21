## Echo Framework Configuration

Echo is a high-performance HTTP web framework for Go applications.

Template Usage: customize configuration for specific Echo application requirements. If your app source is not at the repository root, add a `source.root` entry pointing to the relative path.

Example (typical minimal configuration):

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

If sources live in a subdirectory, add a source root block:

```yaml
applications:
  app:
    source:
      root: path/to/code
    type: golang:1.25
    # ...rest as above
```

Configuration Details

- Runtime Version: use the exact Go runtime `golang:1.25` to match the build environment.
- Build Process: prefer an existing Makefile for complex builds; otherwise use `go build -o <binary>` with an explicit binary name.
- Binary Name: ensure the `web.commands.start` value matches the binary produced by the build hook.
- Database: many Echo apps use SQLite in development — this requires a writable mount for the DB file.

Build Configuration

With Makefile: inspect the Makefile to determine the production target and resulting binary name; match the start command to that binary.

Without Makefile (explicit build hook):

```yaml
hooks:
  build: |
    set -ex
    go build -o app .
```

Database Options

SQLite (common for examples):
- Detection: check imports for `github.com/mattn/go-sqlite3` or `gorm.io/driver/sqlite`.
- Configuration: no external DB service required; ensure the DB file is on a writable mount.
- Typical storage mapping:

```yaml
mounts:
  storage:
    source: storage
```

Map your DB path to that mount (common paths: `./app.db`, `./storage/app.db`, `./data/app.db`).

PostgreSQL (production-ready):
- Add a DB service, a relationship, and expose a DATABASE_URL at build/runtime.

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
- Use the DSN format appropriate for your driver (e.g. `go-sql-driver/mysql`).

```yaml
hooks:
  build: |
    go build -o app .
    echo >> .environment 'export DSN="$DB_USERNAME:$DB_PASSWORD@($DB_HOST:$DB_PORT)/$DB_PATH"'

services:
  db:
    type: mariadb:11.4
```

Notes and Gotchas

- Ensure the build-produced binary name matches the start command.
- For SQLite, always place the DB file on a writable mount to avoid runtime failures.
- When using environment injection in build hooks, persist values to an environment file (as shown) so the runtime picks them up.
