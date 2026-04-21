## Go Application Configuration

Reference configuration pattern for Go applications on Upsun.

Usage Instructions:
- Adapt this template to project-specific requirements.
- Do not copy explanatory comments into production configurations.
- Modify build commands, binary names, and paths as needed.

YAML example (basic web app with PostgreSQL):

applications:
  example:
    type: golang:1.25

    hooks:
      build: |
        set -ex
        go build -o server ./...

        # Build a URL for the database relationship named "db".
        echo >> .environment 'export DATABASE_URL="postgres://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'

    variables:
      env:
        GOPRIVATE: github.com/example-org

    web:
      commands:
        # Avoid "go run" in the start command; compile in build hook.
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

Configuration Notes:
- Runtime Version: use the listed Go runtime (golang:1.25); change only if your project requires a different supported version.
- Build Command: adapt binary name and package path; use a Makefile target if preferred (e.g. make build).
- Private Dependencies: set GOPRIVATE if the project uses private Go modules (check go.mod).
- Static Files: adjust the web.locations.root to the directory that contains served static assets.
- Services: include a database service only if the application requires SQL storage.

Database Options

Go applications can use many databases. Check go.mod or README to determine what the app expects.

PostgreSQL (recommended driver like pgx): set DATABASE_URL in the build hook as shown above.

MariaDB / MySQL (go-sql-driver/mysql) expects a different DSN format:

# Example build hook line for MySQL/MariaDB DSN
echo >> .environment 'export DSN="$DB_USERNAME:$DB_PASSWORD@($DB_HOST:$DB_PORT)/$DB_PATH"'

Workers

Go apps may include multiple long-running processes (web server, workers, migration tools). Run long-running processes as Upsun workers when appropriate.

Example with web, migrator, and queue worker:

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

Notes:
- Use the build hook to produce all binaries; use deploy to run migrations.
- Keep runtime start commands minimal and avoid compiling at runtime.
