# Upsun config reference

## Service type strings

Exact type strings for `services:` in `.upsun/config.yaml`:

| Service | Correct type | Common mistakes |
|---|---|---|
| PostgreSQL | `postgresql:16` | ~~postgres:16~~, ~~pg:16~~ |
| MariaDB | `mariadb:11` | ~~mysql:11~~ |
| MySQL | `mysql:8.0` | |
| Redis | `redis:7.2` | ~~redis-cache:7.2~~ |
| Valkey | `valkey:8` | (Redis fork) |
| Elasticsearch | `elasticsearch:8.5` | |
| OpenSearch | `opensearch:2` | ~~elasticsearch:2~~ |
| MongoDB | `mongodb:7.0` | |
| RabbitMQ | `rabbitmq:4.0` | |
| Kafka | `kafka:3.7` | |
| Memcached | `memcached:1.6` | |
| InfluxDB | `influxdb:2.7` | |
| Solr | `solr:9` | |
| Varnish | `varnish:6.0` | |
| Headless Chrome | `chrome-headless:131` | |
| Network Storage | `network-storage:2.0` | |
| Vault KMS | `vault-kms:1.1` | |
| Gotenberg | `gotenberg:8` | |
| Mercure | `mercure:0.16` | |
| ClickHouse | `clickhouse:24` | |

Full version lists: `upsun service:list`

## Application type strings

| Runtime | Correct type |
|---|---|
| PHP | `php:8.4` (not `php:8.4-fpm`, not `php:latest`) |
| Node.js | `nodejs:22` (not `node:22`) |
| Python | `python:3.12` |
| Go | `golang:1.24` (not `go:1.24`) |
| Java | `java:21` |
| Ruby | `ruby:3.3` |
| .NET | `dotnet:8.0` (not `dotnetcore`, not `aspnet`) |
| Rust | `rust:1` |
| Composable | `composable:latest` |

### Composable images (multi-runtime)

```yaml
applications:
  myapp:
    type: 'composable:latest'
    stack:
      runtimes:
        - 'php@8.4'
        - 'nodejs@22'
```

## Mounts

| Source type | Behavior |
|---|---|
| `storage` | Persistent, shared across instances, network filesystem |
| `tmp` | Instance-specific, max 8GB, may be removed during maintenance |
| `instance` | Dedicated per-instance local storage |

```yaml
mounts:
  "uploads":
    source: storage
    source_path: uploads
```

## PHP-specific configuration

```yaml
runtime:
  extensions:
    - pdo_pgsql
    - redis
  disabled_extensions:
    - opcache
  sizing_hints:
    request_memory: 10
    reserved_memory: 70
  request_terminate_timeout: 300
build:
  flavor: composer    # 'none' skips default build steps
```

Install PHP extensions via `runtime.extensions`, NOT `apt-get` or `pecl` in build hooks.

## Web locations

```yaml
web:
  locations:
    "/":
      root: "public"
      passthru: "/index.php"
      headers:
        X-Frame-Options: SAMEORIGIN
```

Configure routing through `web.locations`, NOT nginx.conf or .htaccess.

## Source operations

```yaml
source:
  operations:
    update-deps:
      command: |
        set -e
        composer update
        git add composer.lock
        git commit -m "Update dependencies" --allow-empty
```

Trigger: `upsun source-operation:run --operation update-deps`

To automate via cron, install the CLI in the build hook and set `UPSUN_CLI_TOKEN` as a variable. Use `--no-wait --yes` flags.

## Additional config properties

| Property | Example | Notes |
|---|---|---|
| `timezone` | `'America/New_York'` | Default: UTC |
| `build.flavor` | `none`, `composer` | `none` skips default build |
| `additional_hosts` | `legacy-api: "10.0.0.5"` | Custom hostname mappings |
| `container_profile` | `HIGH_CPU` | CPU-to-memory ratio |
