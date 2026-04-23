## Gin Application Configuration

Gin is a high-performance HTTP web framework for Go applications.

**Configuration Approach**: Use standard Go application configuration patterns (compile in build hook, set runtime env via .environment) with Gin-specific build and start commands. Build your binary during the build hook and avoid `go run` in production.

**Service Requirements**: Inspect go.mod and the README for database, cache, or other managed-service needs (Postgres, MariaDB/MySQL, Redis, etc.). If your app needs a database, add a relationship and a matching service entry.

**Reference**: Apply the Go per-group guidance but use the Gin-specific build/start pattern shown below.

### Minimal example

```yaml
applications:
  app:
    type: golang:1.26

    hooks:
      build: |
        set -ex
        # Build the Gin web server. Adjust package path as needed (./cmd/server is common).
        go build -o server ./cmd/server

        # If using a PostgreSQL relationship named 'db', export a DATABASE_URL for runtime.
        echo >> .environment 'export DATABASE_URL="postgres://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'

    variables:
      env:
        GOPRIVATE: github.com/example-org

    web:
      commands:
        # Start the compiled Gin binary. Gin commonly reads PORT; pass it explicitly.
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
    type: postgresql:18
```

Configuration notes
- Runtime: use golang:1.26 (from the registry snapshot). Adjust if your project requires an older supported Go runtime.
- Build: compile during the build hook; set the binary name and package path to match your project layout (for example, `./cmd/server`).
- Start: start the compiled binary in `web.commands.start`; pass `$PORT` to the server if it does not autodetect the environment.
- Static files: set `web.locations./.root` to the directory Gin uses for static assets (often `public`). Use `passthru: true` so requests not matching static files are forwarded to the application.

Database setup

If your Gin app uses PostgreSQL, write the canonical DATABASE_URL in the build hook so the app can consume it at runtime:

```sh
# In build hook
echo >> .environment 'export DATABASE_URL="postgres://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'
```

If the app instead uses MySQL/MariaDB (e.g. via go-sql-driver/mysql), set a DSN instead:

```sh
# In build hook
echo >> .environment 'export DSN="$DB_USERNAME:$DB_PASSWORD@($DB_HOST:$DB_PORT)/$DB_PATH"'
```

Workers

If your repository contains additional Go commands (migrations, queue workers), build them in the same build hook and add them as Upsun workers. Example:

```yaml
applications:
  app:
    type: golang:1.26

    hooks:
      build: |
        set -ex
        go build -o server ./cmd/server
        go build -o migrate ./cmd/migrate
        go build -o worker ./cmd/worker
        echo >> .environment 'export DATABASE_URL="postgres://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_PATH"'
      deploy: |
        set -ex
        ./migrate up

    web:
      commands:
        start: ./server --port=$PORT

    workers:
      queue:
        commands:
          start: ./worker --queue=default

    relationships:
      db: {}

services:
  db:
    type: postgresql:18
```

Advanced location rules (static asset expiry)

```yaml
web:
  locations:
    /:
      root: public
      passthru: true
      index: [index.html]
      expires: 5m
      rules:
        '^\.(css|js|png|jpg|svg|webp)$':
          expires: 24h
```

Gotchas and recommendations
- Do not use `go run` for production; compile a binary in the build hook.
- Avoid committing secret-like values. For sensitive values, document creation via Upsun variables and reference them in `.environment` (or expect them to be provided by the environment).
- If your project uses private Go modules, set GOPRIVATE in `variables.env` or in the build hook.
- Ensure any `relationships:` entry has a matching `services:` entry (or is an app-to-app relationship). Orphan relationships will not provide the expected $NAME_* env vars.

Remember to verify runtime and service versions against the canonical registry before committing — registry URL: https://meta.upsun.com/images
