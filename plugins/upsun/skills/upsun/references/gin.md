## Gin Application Configuration

Gin is a high-performance HTTP web framework for Go applications.

Configuration approach

- Use standard Go application configuration patterns (environment variables, config files, or a config package) and treat Gin-specific settings as runtime options (GIN_MODE, trusted proxies, timeouts).
- Build statically when possible for small containers (GOOS=linux, CGO_ENABLED=0).
- Set GIN_MODE=release in production.

Runtime

- Use Go runtime: golang:1.25

Build / packaging

- Typical local build:
  - go mod download
  - CGO_ENABLED=0 GOOS=linux go build -o bin/server ./cmd/server

- Minimal multi-stage Dockerfile example:

  FROM golang:1.25 AS builder
  WORKDIR /src
  COPY go.mod go.sum ./
  RUN go mod download
  COPY . .
  RUN CGO_ENABLED=0 GOOS=linux go build -o /app ./cmd/server

  FROM gcr.io/distroless/static
  COPY --from=builder /app /app
  ENV GIN_MODE=release
  ENTRYPOINT ["/app"]

Service requirements

- Inspect project imports to identify managed services (database, cache, message broker).
- Common services used with Gin apps:
  - PostgreSQL (postgresql:16)
  - MariaDB (mariadb:11.4)
  - Redis (redis:7.4)
  - Valkey (valkey:8) if using secret storage

Minimal service YAML examples (valid YAML, illustrative)

- PostgreSQL + Redis:

  services:
    postgres:
      image: postgres:16
      env:
        POSTGRES_USER: app
        POSTGRES_PASSWORD: secret
        POSTGRES_DB: appdb

    redis:
      image: redis:7.4

Database connection env vars (example)

- DATABASE_URL=postgres://app:secret@postgres:5432/appdb?sslmode=disable
- REDIS_URL=redis://redis:6379

Gin-specific configuration notes and gotchas

- GIN_MODE
  - Set GIN_MODE=release in production. Development defaults to debug which is noisy and slower.

- Trusted proxies
  - Configure trusted proxies when behind load balancers (gin.SetTrustedProxies or GIN_TRUSTED_PROXIES) to ensure correct client IPs.

- Graceful shutdown
  - Use http.Server with Shutdown(context) and a context timeout to allow Gin handlers to exit cleanly.

- Middleware order
  - Order matters. Register recovery, logging, request ID, and auth middleware in the correct sequence.

- Timeouts
  - Set sensible server timeouts (ReadTimeout, WriteTimeout, IdleTimeout) to avoid resource exhaustion under load.

- Error handling
  - Centralize response formatting for errors (status codes and JSON bodies) to keep handlers consistent.

Workers / background jobs

- Run background workers as separate processes or goroutines launched from main. Prefer separate process for long-running job systems so lifecycle is independent from the HTTP process.
- Use a managed queue (Redis, RQ, or a database-backed job table) depending on project needs.

Options / tips

- Use modules (go.mod) and pin versions.
- Run go vet, golangci-lint and go test as part of CI.
- Keep environment-driven configuration minimal and document required env vars (PORT, DATABASE_URL, REDIS_URL, GIN_MODE).

Reference

- Follow general Go per-group guidance and apply the build and service patterns above for Gin-specific projects.
