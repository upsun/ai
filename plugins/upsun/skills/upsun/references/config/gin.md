## Gin Application Configuration

Gin is a high-performance HTTP web framework for Go applications.

This reference covers Gin-specific build commands, runtime settings, environment conventions, and minimal examples for managed services commonly used with Gin apps.

## Supported runtime

- Go runtime: golang:1.25

## Build & release

- Build statically when possible for simpler deployment. Use module-aware builds (Go modules).
- Common build command (replace ./cmd/server with your main package path):

```bash
GOFLAGS="" CGO_ENABLED=0 go build -mod=readonly -trimpath -ldflags="-s -w" -o ./bin/server ./cmd/server
```

- For quick local/dev run:

```bash
# run with go run
go run ./cmd/server
```

- Recommended production start (use environment variables for port and mode):

```bash
GIN_MODE=release PORT=8080 ./bin/server
```

## Runtime settings

- Always bind the HTTP server to 0.0.0.0 so the container/pod can receive external traffic.
- Read the port from environment (example using PORT):

```go
port := os.Getenv("PORT")
if port == "" { port = "8080" }
router.Run("0.0.0.0:" + port)
```

- Set Gin mode via GIN_MODE (release, debug, test). For production use GIN_MODE=release.

- Implement graceful shutdown using context and server.Shutdown to avoid dropped requests on restarts.

## Managed services (common)

Example minimal service definitions (image tags use current registry versions):

```yaml
services:
  - name: postgres
    image: postgres:16
    env:
      POSTGRES_USER: app
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: app_db

  - name: redis
    image: redis:7.4
```

Application should read DATABASE_URL or individual connection variables (HOST, PORT, USER, PASSWORD, DB) depending on your driver setup.

Use the pgx or database/sql + lib/pq driver for PostgreSQL, and go-redis for Redis.

## Worker processes and background jobs

- If your app uses background workers (job queues, scheduled tasks), run them as separate processes to simplify scaling and lifecycle management.
- Example commands:

```bash
# web process
./bin/server
# worker process
./bin/worker
```

Implement idempotency in jobs and use a work queue (Redis, PostgreSQL advisory locks, or specialized queue) for resilience.

## Environment & configuration options

- Common env vars:
  - PORT — HTTP listening port
  - GIN_MODE — release|debug|test
  - DATABASE_URL — postgres://user:pass@host:port/dbname
  - REDIS_URL — redis://host:port
  - LOG_LEVEL — info|debug|warn|error

- Consider using a small configuration loader (env + file) and validate required vars on startup.

## Examples

Minimal GitHub Actions build example for Go 1.25:

```yaml
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v4
        with:
          go-version: '1.25'
      - run: go test ./...
      - run: GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o bin/server ./cmd/server
```

## Gotchas

- Do not rely on Gin's default port; always use env-configured port for portability.
- Ensure database connection pools are closed on shutdown.
- Avoid binding to localhost in containers (use 0.0.0.0).
- When cross-compiling or building in CI, set CGO_ENABLED appropriately; static builds (CGO_ENABLED=0) are simpler for many deployments.

## Further notes

- Follow the generic Go per-group guidance for module, caching, and build optimization.
- Keep web and worker processes separate to make horizontal scaling straightforward.
