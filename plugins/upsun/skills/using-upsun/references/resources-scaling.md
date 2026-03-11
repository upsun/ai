# Resource Scaling and Performance

Complete guide to managing resources, autoscaling, and monitoring performance on Upsun.

## Overview

Upsun allows fine-grained control over resource allocation for applications and services. Understanding resource management is crucial for cost optimization and performance.

**Resource Types:**
- **CPU** - Processing power allocation
- **Memory (RAM)** - Application memory
- **Disk** - Persistent storage
- **Container Profiles** - Predefined resource combinations

## Viewing Resources

### View Current Resources

Get current resource allocation for an environment:

```bash
upsun resources:get -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Aliases:** `resources`, `res`

**Example:**
```bash
upsun resources -p abc123 -e production
```

**Example output:**
```yaml
applications:
  app:
    size: L
    cpu: 2.0
    memory: 4096
    disk: 5120

services:
  database:
    size: M
    cpu: 1.0
    memory: 2048
    disk: 10240
```

### List Available Container Sizes

View all available container profile sizes:

```bash
upsun resources:size:list
```

**Alias:** `resources:sizes`

**Output:**
```
+------+-------+--------+------------+
| Size | CPU   | Memory | Base Cost  |
+------+-------+--------+------------+
| XS   | 0.25  | 512MB  | Low        |
| S    | 0.5   | 1024MB | Low        |
| M    | 1.0   | 2048MB | Medium     |
| L    | 2.0   | 4096MB | Medium     |
| XL   | 4.0   | 8192MB | High       |
| 2XL  | 8.0   | 16384MB| Very High  |
+------+-------+--------+------------+
```

## Setting Resources

### Set Application Resources

Allocate resources to applications and services:

```bash
upsun resources:set -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Interactive mode:**
```bash
upsun resources:set -p abc123 -e production
# Follow prompts to select resources
```

**Set specific application size:**
```bash
upsun resources:set -p abc123 -e production --size app:L
```

**Set multiple resources:**
```bash
upsun resources:set -p abc123 -e production \
  --size app:L \
  --size database:M \
  --size redis:S
```

**⚠️ Note:** Resource changes require environment redeployment.

**Complete workflow:**
```bash
# 1. View current resources
upsun resources -p abc123 -e production

# 2. Create backup before change
upsun backup:create -p abc123 -e production

# 3. Set new resources
upsun resources:set -p abc123 -e production --size app:XL

# 4. Redeploy to apply
upsun redeploy -p abc123 -e production

# 5. Monitor deployment
upsun activity:list -p abc123 -e production -i

# 6. Verify new resources
upsun resources -p abc123 -e production
```

### Build Resources

Configure resources for build phase:

```bash
upsun resources:build:get -p PROJECT_ID
```

**View build resources:**
```bash
upsun build-resources -p abc123
```

**Set build resources:**
```bash
upsun resources:build:set -p abc123
```

**Use cases:**
- Increase memory for large compilations
- More CPU for parallel builds
- Temporary boost for asset compilation

## Autoscaling

### View Autoscaling Configuration

Check current autoscaling settings:

```bash
upsun autoscaling:get -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Alias:** `autoscaling`

**Example:**
```bash
upsun autoscaling -p abc123 -e production
```

**Output:**
```yaml
app:
  enabled: true
  min_instances: 2
  max_instances: 10
  target_cpu: 70
  target_memory: 80
```

### Configure Autoscaling

Set autoscaling parameters:

```bash
upsun autoscaling:set -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Enable autoscaling:**
```bash
upsun autoscaling:set -p abc123 -e production \
  --min 2 \
  --max 10 \
  --target-cpu 70
```

**Disable autoscaling:**
```bash
upsun autoscaling:set -p abc123 -e production --disable
```

**Parameters:**
- `--min` - Minimum instances (always running)
- `--max` - Maximum instances (scale limit)
- `--target-cpu` - CPU threshold for scaling (%)
- `--target-memory` - Memory threshold for scaling (%)

**Best practices:**
- Set `min` to handle base load
- Set `max` based on budget and traffic
- Use 70-80% CPU/memory targets
- Monitor metrics after enabling

## Performance Metrics

### View All Metrics

Get comprehensive performance metrics:

```bash
upsun metrics:all -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Aliases:** `metrics`, `met`

**Example:**
```bash
upsun metrics -p abc123 -e production
```

**Includes:**
- CPU usage over time
- Memory consumption
- Disk usage
- Network I/O

### CPU Metrics

Monitor CPU usage:

```bash
upsun metrics:cpu -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Alias:** `cpu`

**Options:**
- `--start TIME` - Start time (e.g., "-1 hour", "2025-01-01")
- `--end TIME` - End time
- `--interval MINUTES` - Data point interval

**Examples:**

**Last hour:**
```bash
upsun cpu -p abc123 -e production --start "-1 hour"
```

**Specific time range:**
```bash
upsun cpu -p abc123 -e production \
  --start "2025-01-07 09:00" \
  --end "2025-01-07 17:00"
```

**Interpretation:**
- **< 50%** - Underutilized, consider downsizing
- **50-80%** - Healthy utilization
- **80-95%** - Consider scaling up
- **> 95%** - Critical, scale immediately

### Memory Metrics

Monitor memory usage:

```bash
upsun metrics:memory -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Aliases:** `mem`, `memory`

**Example:**
```bash
upsun memory -p abc123 -e production --start "-24 hours"
```

**Warning signs:**
- Consistently > 90% - Risk of OOM errors
- Sudden spikes - Memory leaks
- Gradual increase - Application memory leak

**Actions:**
- Scale up memory allocation
- Investigate memory leaks
- Optimize application code
- Add caching layer

### Disk Usage

Monitor disk consumption:

```bash
upsun metrics:disk-usage -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Alias:** `disk`

**Example:**
```bash
upsun disk -p abc123 -e production
```

**By mount:**
```bash
upsun disk -p abc123 -e production --mount /app/storage
```

**Disk management:**
- Monitor upload directories
- Clean old log files
- Archive old data
- Implement log rotation

## Performance Monitoring Workflow

### Daily Health Check

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"

echo "=== Daily Health Check: $ENV ==="
echo "Date: $(date)"

# CPU usage
echo "\n--- CPU (last 24h) ---"
upsun cpu -p $PROJECT -e $ENV --start "-24 hours" | tail -n 5

# Memory usage
echo "\n--- Memory (last 24h) ---"
upsun memory -p $PROJECT -e $ENV --start "-24 hours" | tail -n 5

# Disk usage
echo "\n--- Disk Usage ---"
upsun disk -p $PROJECT -e $ENV

# Resource allocation
echo "\n--- Current Resources ---"
upsun resources -p $PROJECT -e $ENV

# Autoscaling status
echo "\n--- Autoscaling ---"
upsun autoscaling -p $PROJECT -e $ENV

# Recent activities
echo "\n--- Recent Activities ---"
upsun activity:list -p $PROJECT -e $ENV --limit 5
```

### Performance Alert Script

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"
CPU_THRESHOLD=90
MEMORY_THRESHOLD=90
DISK_THRESHOLD=85

# Check CPU
CPU_USAGE=$(upsun cpu -p $PROJECT -e $ENV --start "-5 minutes" | grep -oP '\d+(?=%)' | tail -n 1)
if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
    echo "🚨 ALERT: High CPU usage: ${CPU_USAGE}%"
    # Send notification (email, Slack, etc.)
fi

# Check Memory
MEM_USAGE=$(upsun memory -p $PROJECT -e $ENV --start "-5 minutes" | grep -oP '\d+(?=%)' | tail -n 1)
if [ "$MEM_USAGE" -gt "$MEMORY_THRESHOLD" ]; then
    echo "🚨 ALERT: High memory usage: ${MEM_USAGE}%"
fi

# Check Disk
DISK_USAGE=$(upsun disk -p $PROJECT -e $ENV | grep -oP '\d+(?=%)' | tail -n 1)
if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo "🚨 ALERT: High disk usage: ${DISK_USAGE}%"
fi
```

## Resource Optimization

### Right-Sizing Resources

**Evaluation process:**

1. **Collect metrics** (2-4 weeks):
   ```bash
   upsun metrics -p abc123 -e production --start "-30 days"
   ```

2. **Analyze patterns:**
   - Peak usage times
   - Average utilization
   - Growth trends
   - Traffic patterns

3. **Calculate requirements:**
   - Peak CPU + 20% headroom
   - Peak Memory + 20% headroom
   - Disk with 30% free space

4. **Adjust resources:**
   ```bash
   upsun resources:set -p abc123 -e production --size app:M
   ```

5. **Monitor after changes** (1-2 weeks):
   ```bash
   upsun metrics -p abc123 -e production
   ```

### Cost Optimization

**Strategies:**

**1. Use autoscaling:**
```bash
# Scale down during low traffic
upsun autoscaling:set -p abc123 -e production \
  --min 1 \
  --max 5 \
  --target-cpu 75
```

**2. Pause dev environments:**
```bash
# Pause at night
upsun environment:pause -p abc123 -e dev-testing

# Resume in morning
upsun environment:resume -p abc123 -e dev-testing
```

**3. Right-size services:**
```bash
# Reduce oversized services
upsun resources:set -p abc123 -e staging \
  --size app:S \
  --size database:S
```

**4. Delete unused environments:**
```bash
# List inactive environments
upsun environment:list -p abc123 | grep Inactive

# Delete old ones
upsun environment:delete -p abc123 -e old-feature
```

### Performance Tuning

**Application-level:**
- Enable caching (Redis/Valkey)
- Optimize database queries
- Implement CDN for static assets
- Use async processing for heavy tasks
- Enable compression

**Infrastructure-level:**
- Use autoscaling for traffic spikes
- Allocate sufficient memory for caching
- Use appropriate container sizes
- Enable HTTP/2
- Configure proper PHP/Node.js settings

## Worker Resources

### List Workers

View deployed workers:

```bash
upsun worker:list -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Alias:** `workers`

**Example:**
```bash
upsun workers -p abc123 -e production
```

**Output:**
```
+---------------+----------+------+--------+
| Name          | Type     | Size | Status |
+---------------+----------+------+--------+
| queue-worker  | worker   | M    | Active |
| scheduler     | worker   | S    | Active |
+---------------+----------+------+--------+
```

### Set Worker Resources

Configure worker resources same as applications:

```bash
upsun resources:set -p abc123 -e production --size queue-worker:L
```

## Best Practices

### Monitoring

- Check metrics daily
- Set up alerts for thresholds
- Monitor during deployments
- Track trends over time
- Document baseline performance

### Scaling

- Scale proactively, not reactively
- Test scaling on staging first
- Use autoscaling for predictable patterns
- Keep 20-30% resource headroom
- Monitor cost vs performance

### Resource Allocation

- Start small, scale up as needed
- Match resources to workload
- Separate resource-intensive services
- Use appropriate container sizes
- Review allocations quarterly

## Related Commands

**Environments:**
- `environment:info` - Environment status
- `environment:pause/resume` - Save costs
- See [environments.md](environments.md)

**Monitoring:**
- `environment:logs` - Application logs
- `activity:list` - Deployment activities
- See [development-tools.md](development-tools.md)

**Services:**
- `service:list` - View service resources
- See [services-databases.md](services-databases.md)

## Troubleshooting

**High CPU usage:**
- Check for infinite loops
- Review recent deployments
- Check for DDoS attacks
- Optimize database queries
- Consider scaling up

**High memory usage:**
- Check for memory leaks
- Review caching strategy
- Check uploaded file sizes
- Optimize image processing
- Scale up memory

**Disk full:**
- Clean up log files
- Remove old uploads
- Archive old data
- Increase disk allocation
- Implement cleanup cron

**Autoscaling not working:**
- Verify enabled: `autoscaling:get`
- Check thresholds are appropriate
- Review metrics during traffic
- Ensure max > min instances
- Check for resource limits

For more troubleshooting, see [troubleshooting.md](troubleshooting.md).
