## Gin Application Configuration

Gin is a high-performance HTTP web framework for Go applications.

### Configuration approach

- Use standard Go project layouts (cmd/, internal/, pkg/, etc.).
- Build a single binary for the web process and run it as the service entrypoint.
- Respect the PORT environment variable (common platform convention).

### Build & run (recommended)

- Build command (example):

  go mod download
  go build -o /app/bin/server ./cmd/server

- Start command (example):

  /app/bin/server

- Ensure your main reads PORT (default 8080) and binds to 0.0.0.0.

### Environment and runtime

- Recommended Go runtime: golang:1.25
- Common env vars:
  - PORT (default 8080)
  - GIN_MODE (set to "release" in production)
  - DATABASE_URL or separate DB_HOST/DB_PORT/DB_USER/DB_PASS

- Set GOMAXPROCS to the number of CPU cores (Go 1.25 handles this automatically, but explicit settings are acceptable).

### Service requirements

- Databases & caches (typical managed versions):
  - postgresql:16
  - mariadb:11.4
  - redis:7.4
  - valkey:8

- Migration strategy: run migrations as a separate one-off job or at release time. Example tools: golang-migrate, goose. Example migrate command:

  migrate -path ./migrations -database "$DATABASE_URL" up

### Gin-specific gotchas

- GIN_MODE must be set to "release" in production to avoid debug logging and performance penalties.
- Use graceful shutdown (context with server.Shutdown) to allow in-flight requests to complete.
- If serving static files, prefer embedding (embed.FS) or a dedicated static file server to reduce binary complexity.
- Avoid relying on a current working directory; use explicit paths or embedded assets.

### Example minimal Upsun service snippet (YAML)

services:
  web:
    build:
      image: golang:1.25
      commands:
        - go mod download
        - go build -o /app/bin/server ./cmd/server
    start_command: /app/bin/server
    env:
      PORT: 8080
      GIN_MODE: release
    ports:
      - 8080

### Worker / background jobs

- Run workers as separate services/processes. Build the same Go binary or a dedicated worker binary.
- Use the same Go runtime image for build to reuse caching and modules.

### Notes

- Keep configuration minimal in the binary; prefer environment variables for secrets and service endpoints.
- Review dependency imports to ensure no unexpected native dependencies that require additional system packages.
