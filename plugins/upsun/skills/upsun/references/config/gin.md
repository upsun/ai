## Gin Application Configuration

Gin is a high-performance HTTP web framework for Go applications.

Configuration Approach: Use standard Go application configuration patterns with Gin-specific build and start commands. Build your binary during the build hook (avoid go run in production) and expose any service URLs via a .environment file.

Service Requirements: Inspect the project for database, cache, or queue dependencies (check go.mod, README or cmd packages). If you need a database, declare a relationship and a matching service entry.

Reference (Go + Gin)

- Runtime: golang:1.26 (example uses the highest supported Go runtime from the registry snapshot)
- Typical build: compile a single server binary from your cmd entrypoint
- Start command: run the compiled binary and bind to $PORT

Example Upsun config for a Gin-based app

```yaml
applications:
  app:
    type: golang:1.26

    hooks:
      build: |
        set -ex
        # Build the server binary from the typical cmd/server entrypoint. Adjust if your project layout differs.
        go build -o server ./cmd/server

        # If using PostgreSQL via a relationship named 'db', expose a DATABASE_URL for your app.
        echo >> .environment 'export DATABASE_URL="postgres://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'

    variables:
      env:
        # Example for private modules; adjust or remove if not needed.
        GOPRIVATE: github.com/example-org

    web:
      commands:
        # Start the compiled binary and use the $PORT provided by the platform
        start: ./server --port=$PORT

      locations:
        '/':
          root: public
          passthru: true
          index: [index.html]

    relationships:
      db: {}

services:
  db:
    type: postgresql:18
```

Workers and extra commands

If your repository includes additional long-running programs (workers, queue processors), build them in the same build hook and declare a worker entry:

```yaml
applications:
  app:
    hooks:
      build: |
        set -ex
        go build -o server ./cmd/server
        go build -o worker ./cmd/worker
        echo >> .environment 'export DATABASE_URL="postgres://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'

    web:
      commands:
        start: ./server --port=$PORT

    workers:
      queue-processor:
        commands:
          start: ./worker --queue=default

    relationships:
      db: {}

services:
  db:
    type: postgresql:18
```

Configuration notes and gotchas

- Runtime version: This reference uses golang:1.26 (choose the appropriate Go version from the registry for your project).
- Build command: adapt binary name, package path, or use a Makefile if your project uses one (e.g. `make build`).
- Private modules: set GOPRIVATE when using private Go modules.
- Static files: set web.locations./.root to the directory your Gin app serves static assets from.
- Database URLs: for PostgreSQL use the `postgres://` scheme as shown. For MySQL/MariaDB use the appropriate DSN format (see language docs if needed).
- Services/Relationships: every relationships entry must have a corresponding services entry (or an application with that name).

Database example

The example above exposes DATABASE_URL via the build hook when a relationship named `db` is present:

```sh
# Build hook snippet that writes .environment
echo >> .environment 'export DATABASE_URL="postgres://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'
```

Reminder

- The versions used in examples (golang:1.26 and postgresql:18) are taken from the provided registry snapshot. Always verify image versions against the canonical registry before committing: https://meta.upsun.com/images
