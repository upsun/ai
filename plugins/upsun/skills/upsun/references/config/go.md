## Go Application Configuration

Reference configuration pattern for Go applications on Upsun.

**Usage Instructions**:
- Adapt this template to project-specific requirements
- Do not copy comments into production configurations
- Modify build commands, binary names, and paths as needed

```yaml
applications:
  example:
    type: golang:1.25

    hooks:
      build: |
        set -ex
        go build -o server ./...

        # Build a URL for the database relationship named "db". (Only include if a database is wanted).
        echo >> .environment 'export DATABASE_URL="postgres://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'

    variables:
      env:
        GOPRIVATE: github.com/example-org

    web:
      commands:
        # Avoid "go run" in the start command; it's best to compile during the build hook.
        start: ./server --port=$PORT

      locations:
        /:
          root: public
          passthru: true
          index: [index.html]

    relationships:
      db: {}

services:
  db:
    type: postgresql:16
```

**Configuration Notes**:
- **Runtime Version**: Choose appropriate Go version from Registry (example uses golang:1.25)
- **Build Command**: Adapt binary name and package path, use Makefile if available (`make build`)
- **Private Dependencies**: Set GOPRIVATE if project uses private Go modules (check Makefile, go.mod)
- **Static Files**: Adjust `root` path to match where application serves static content
- **Services**: Include database only if project requires SQL storage
- **Database Setup**: See below

### Database Options

Go applications can use many types of database (or none): check the go.mod or README for indications on what the application expects.

If using PostgreSQL (as above), the Go driver package (such as `pgx`) probably needs a URL format with `postgres` as the scheme, provided by this command in the build hook:

```sh
# Assuming relationship name 'db' (providing variables prefixed with DB_).
echo >> .environment 'export DATABASE_URL="postgres://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'
```

However, if using MariaDB or MySQL, the application probably uses `go-sql-driver/mysql` which needs a different DSN format:

```sh
echo >> .environment 'export DSN="$DB_USERNAME:$DB_PASSWORD@($DB_HOST:$DB_PORT)/$DB_PATH"'
```

### Workers

Go applications may have multiple entrypoint commands, for example, a web server and a queue processing worker.

If the extra command(s) should be long-running processes and share the same configuration as the application, then they can be run as an Upsun worker container, for example:

```yaml
# An example Go project with a web server, a database migration tool, and a queue processing worker.
applications:
  app:
    hooks:
      build: |
        set -ex
        go build -o server ./cmd/server
        go build -o migrate ./cmd/migrate
        go build -o queue-processor ./cmd/queue_processor
        echo >> .environment 'export DSN="$DB_USERNAME:$DB_PASSWORD@($DB_HOST:$DB_PORT)/$DB_PATH"'
      deploy: ./migrate up

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
    type: mariadb:11.4
```
