## Echo Framework Configuration

Echo is a high-performance HTTP web framework for Go applications.

Usage: customize this config for your Echo application. For production configs avoid explanatory comments.

Example configuration (minimal):

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

If your application code lives in a subdirectory, add a source root block:

```yaml
applications:
  app:
    source:
      root: path/to/app
    type: golang:1.25
    # ...
```

Configuration details

- Runtime version: use golang:1.25 for Go/Echo applications.
- Build process: prefer an existing Makefile; otherwise use an explicit go build with an explicit binary name.
- Binary name: ensure the web.start command matches the binary produced by the build step.
- Database: many Echo examples use SQLite — ensure a writable mount for the database file.

Build configuration

With a Makefile: inspect the Makefile for a production target and the produced binary name. Match the start command to that binary.

Without a Makefile, use an explicit binary name:

```yaml
hooks:
  build: |
    set -ex
    go build -o app .
```

Database options

SQLite (common for development/examples):
- Detection: look for imports like github.com/mattn/go-sqlite3 or gorm.io/driver/sqlite.
- Configuration: does not require a database service; it requires a writable mount for the DB file.
- Storage mapping example:

```yaml
mounts:
  storage:
    source: storage
```

Common file locations: ./app.db, ./storage/app.db, ./data/app.db — map whichever path your app writes to the storage mount.

PostgreSQL (production):
- Add a service and relationship, and export DATABASE_URL into the environment during build so runtime picks it up.

```yaml
hooks:
  build: |
    go build -o app .
    echo 'export DATABASE_URL="postgres://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"' >> .environment

relationships:
  db: {}

services:
  db:
    type: postgresql:16
```

MySQL / MariaDB alternative:
- Use the appropriate DSN shape for the MySQL driver (github.com/go-sql-driver/mysql).

```yaml
hooks:
  build: |
    go build -o app .
    echo 'export DSN="$DB_USERNAME:$DB_PASSWORD@($DB_HOST:$DB_PORT)/$DB_PATH"' >> .environment

services:
  db:
    type: mariadb:11.4
```

Notes and gotchas

- Ensure the start command references the exact binary produced by your build step.
- If using SQLite, the database file must be placed on a writable mount; otherwise the app will fail at runtime when attempting writes.
- When adding external databases, prefer injecting DSNs/URLs into the environment during build or startup so the app can read them from runtime environment variables.
