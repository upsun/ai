## Echo Framework Configuration

Echo is a high-performance HTTP web framework for Go applications.

**Template Usage**: Customize configuration for specific Echo application requirements. Do not include explanatory comments in production configurations.

```yaml
applications:
  app:
    type: golang:1.26

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

**Configuration Details**:

- **Runtime Version**: Use exact Go version from Registry matching application requirements
- **Build Process**: Use Makefile if present, otherwise use `go build -o` with explicit binary name
- **Binary Name**: Ensure start command matches the actual binary produced by build process
- **Database**: Many Echo applications use SQLite - requires writable mount for database file storage

### Build Configuration

**With Makefile**: Analyze Makefile to determine:
- Appropriate build target (look for production/static build targets)
- Binary output name (check APP variable or build command output)
- Match start command to the binary name produced

**Without Makefile**: Use explicit binary naming:
```yaml
hooks:
  build: |
    set -ex
    go build -o app .
```

### Database Options

**SQLite** (common for Echo examples):
- **Detection**: Check for SQLite usage in Go imports (`github.com/mattn/go-sqlite3`, `gorm.io/driver/sqlite`)
- **Configuration**: No database service needed, requires writable mount for database file storage
- **Storage**: Map database file path to storage mount (common paths: `./app.db`, `./storage/app.db`, `./data/app.db`)

```yaml
mounts:
  storage:
    source: storage
```

**PostgreSQL** (for production applications):
- Add database service and relationship
- Configure DATABASE_URL in build hook

```yaml
hooks:
  build: |
    go build -o app .
    echo >> .environment 'export DATABASE_URL="postgres://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'

relationships:
  db: {}

services:
  db:
    type: postgresql:18
```

**MySQL/MariaDB Alternative**:
- Use different DSN format for go-sql-driver/mysql

```yaml
hooks:
  build: |
    go build -o app .
    echo >> .environment 'export DSN="$DB_USERNAME:$DB_PASSWORD@($DB_HOST:$DB_PORT)/$DB_PATH"'

services:
  db:
    type: mariadb:11.8
```

### Workers

Go applications may have multiple entrypoints (web server, workers). Build all required binaries during the build hook and define workers in the application block.

```yaml
applications:
  app:
    type: golang:1.26

    hooks:
      build: |
        set -ex
        go build -o server ./cmd/server
        go build -o queue-processor ./cmd/queue_processor

    web:
      commands:
        start: ./server --port=$PORT

    workers:
      process-queue:
        commands:
          start: ./queue-processor --queue=default

    relationships:
      db: {}

services:
  db:
    type: mariadb:11.8
```

Note: Always verify runtime and service versions against the canonical registry before committing, since versions may be deprecated or retired over time: https://meta.upsun.com/images
