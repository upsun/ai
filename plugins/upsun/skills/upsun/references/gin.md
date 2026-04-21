## Gin Application Configuration

Gin is a high-performance HTTP web framework for Go applications.

### Configuration approach
- Use standard Go configuration patterns (env vars, config files, or a config package).
- Ensure builds are module-aware (Go modules). Use golang:1.25 runtime for builds and containers.
- Expose configuration via environment variables: PORT, DATABASE_URL, REDIS_URL, etc.

### Build & run (recommended)
- Local / CI:
  - go mod tidy
  - go test ./...
  - go build -o bin/server ./cmd/server
- Dev quick-run:
  - go run ./cmd/server

Gin-specific tips
- Set Gin to release mode in production: gin.SetMode(gin.ReleaseMode)
- Use net/http Server with Read/Write/Idle timeouts and graceful shutdown handling.
- Prefer secure default middleware (CORS, CSRF if needed, rate-limiting, request size limits).
- Use go:embed for static assets when packaging into a single binary.

### Common runtime environment variables
- PORT (e.g. 8080)
- DATABASE_URL (Postgres, MySQL/MariaDB DSN)
- REDIS_URL
- GIN_MODE (or call gin.SetMode explicitly)

### Databases & services
- Upsun-managed service versions (use these registry images):
  - postgresql:16
  - mariadb:11.4
  - redis:7.4

Minimal example Upsun-style service YAML (valid, replace secrets in production):

services:
  app:
    image: golang:1.25
    command: ["./bin/server"]
    env:
      PORT: "8080"
      DATABASE_URL: "postgres://postgres:password@postgres:5432/appdb?sslmode=disable"
      REDIS_URL: "redis://redis:6379/0"
    ports: ["8080:8080"]
    depends_on: ["postgres", "redis"]

  postgres:
    image: postgres:16
    restart: unless-stopped
    env:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_DB: appdb
    ports: ["5432:5432"]

  redis:
    image: redis:7.4
    ports: ["6379:6379"]

### Migrations and workers
- Run DB migrations before starting the app (e.g. golang-migrate, goose). Example:
  - migrate -path ./migrations -database "$DATABASE_URL" up
- Background jobs: implement in-process workers carefully (supervise goroutines) or run separate worker processes that share the same config and connection strings.

### Gotchas
- Do not run Gin's debug mode in production. Ensure gin.SetMode(gin.ReleaseMode).
- Close DB connections on shutdown and respect context cancellations.
- Configure connection pooling (max open/conns) for SQL drivers to avoid exhaustion.
- Validate and sanitize incoming request data; Gin binds automatically but validation is still required.

### Reference
Apply Go per-group guidance and use the build/run examples above for Gin-specific projects.
