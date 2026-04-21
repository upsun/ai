## PHP Application Configuration

### Build Configuration

**Important**: Always use `flavor: none` for explicit dependency management control.

The default `composer` flavor installs dependencies implicitly without production optimizations, potentially including development packages in production builds.

**Recommended Configuration**:
```yaml
applications:
  example:
    type: php:8.4

    build:
      flavor: none

    hooks:
      build: |
        set -ex
        composer install --no-progress --no-interaction --optimize-autoloader --no-dev
```

**Build Command Explanation**:
- `--no-dev`: Excludes development dependencies
- `--optimize-autoloader`: Optimizes class loading for production
- `--no-interaction`: Prevents interactive prompts
- `--no-progress`: Reduces output verbosity

### Extension Configuration

**Default Extensions**: Most common PHP extensions are pre-installed.

**Additional Extensions**:
```yaml
applications:
  example:
    type: php:8.4
    runtime:
      extensions:
        - sodium
        - redis
        - mongodb
```

### Web Configuration

**PHP-FPM Defaults**:
- **Omit `web.commands.start`** - PHP-FPM starts automatically
- **Omit `web.upstream` settings** - the defaults are correct for PHP-FPM

### Runtime Settings

**PHP Configuration**:
```yaml
applications:
  example:
    type: php:8.4
    variables:
      php:
        memory_limit: 256M
        max_execution_time: 300
        upload_max_filesize: 10M
```

**Environment Variables**:
- **Never put secrets in `variables.env`** - use build hook with a `.environment` file
- **Use `PLATFORM_PROJECT_ENTROPY` for secrets**, for example, Symfony's APP_SECRET

**Common Settings**:
- `memory_limit`: Increase for memory-intensive applications
- `max_execution_time`: Extend for long-running scripts
- `upload_max_filesize`: Adjust for file upload requirements
