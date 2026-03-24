# Resource Scaling and Performance — Reference

Complete guide to managing resources, autoscaling, and monitoring performance on Upsun.

## Overview

Upsun allows fine-grained control over resource allocation for applications and services.

**Resource Types:**
- **CPU** - Processing power allocation
- **Memory (RAM)** - Application memory
- **Disk** - Persistent storage
- **Container Profiles** - Predefined resource combinations

## Viewing Resources

### View Current Resources

```bash
upsun resources:get -p PROJECT_ID -e ENVIRONMENT_NAME
# Aliases: resources, res
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

```bash
upsun resources:size:list
# Alias: resources:sizes
```

Output:
```
+------+-------+--------+
| Size | CPU   | Memory |
+------+-------+--------+
| XS   | 0.25  | 512MB  |
| S    | 0.5   | 1024MB |
| M    | 1.0   | 2048MB |
| L    | 2.0   | 4096MB |
| XL   | 4.0   | 8192MB |
| 2XL  | 8.0   | 16384MB|
+------+-------+--------+
```

## Setting Resources

### Set Application Resources

```bash
upsun resources:set -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Interactive mode:**
```bash
upsun resources:set -p abc123 -e production
```

**Set specific size:**
```bash
upsun resources:set -p abc123 -e production --size app:L
```

**Set multiple resources at once:**
```bash
upsun resources:set -p abc123 -e production \
  --size app:L \
  --size database:M \
  --size redis:S
```

> Resource changes require environment redeployment.

**Complete workflow:**
```bash
upsun resources -p abc123 -e production
upsun backup:create -p abc123 -e production
upsun resources:set -p abc123 -e production --size app:XL
upsun redeploy -p abc123 -e production
upsun activity:list -p abc123 -e production -i
upsun resources -p abc123 -e production
```

### Build Resources

```bash
upsun resources:build:get -p PROJECT_ID       # View build resources
upsun resources:build:set -p PROJECT_ID       # Set build resources
```

Use cases: increase memory for large compilations, more CPU for parallel builds.

## Autoscaling

### View Autoscaling Configuration

```bash
upsun autoscaling:get -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: autoscaling
```

**Example output:**
```yaml
app:
  enabled: true
  min_instances: 2
  max_instances: 10
  target_cpu: 70
  target_memory: 80
```

### Configure Autoscaling

```bash
upsun autoscaling:set -p PROJECT_ID -e ENVIRONMENT_NAME
```

**Enable:**
```bash
upsun autoscaling:set -p abc123 -e production \
  --min 2 \
  --max 10 \
  --target-cpu 70
```

**Disable:**
```bash
upsun autoscaling:set -p abc123 -e production --disable
```

**Parameters:**
- `--min` - Minimum instances (always running)
- `--max` - Maximum instances (scale limit)
- `--target-cpu` - CPU threshold for scaling (%)
- `--target-memory` - Memory threshold for scaling (%)

## Performance Metrics

### View All Metrics

```bash
upsun metrics:all -p PROJECT_ID -e ENVIRONMENT_NAME
# Aliases: metrics, met
```

### CPU Metrics

```bash
upsun metrics:cpu -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: cpu

# Last hour:
upsun cpu -p abc123 -e production --start "-1 hour"

# Specific time range:
upsun cpu -p abc123 -e production \
  --start "2025-01-07 09:00" \
  --end "2025-01-07 17:00"
```

**Interpretation:**
- **< 50%** - Underutilised, consider downsizing
- **50–80%** - Healthy utilisation
- **80–95%** - Consider scaling up
- **> 95%** - Critical, scale immediately

### Memory Metrics

```bash
upsun metrics:memory -p PROJECT_ID -e ENVIRONMENT_NAME
# Aliases: mem, memory

upsun memory -p abc123 -e production --start "-24 hours"
```

**Warning signs:**
- Consistently > 90% - Risk of OOM errors
- Sudden spikes - Memory leaks
- Gradual increase - Application memory leak

### Disk Usage

```bash
upsun metrics:disk-usage -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: disk

upsun disk -p abc123 -e production
upsun disk -p abc123 -e production --mount /app/storage
```

## Performance Monitoring Workflow

### Daily Health Check Script

```bash
#!/bin/bash
PROJECT="abc123"
ENV="production"

echo "=== Daily Health Check: $ENV ==="
echo "Date: $(date)"

echo "\n--- CPU (last 24h) ---"
upsun cpu -p $PROJECT -e $ENV --start "-24 hours" | tail -n 5

echo "\n--- Memory (last 24h) ---"
upsun memory -p $PROJECT -e $ENV --start "-24 hours" | tail -n 5

echo "\n--- Disk Usage ---"
upsun disk -p $PROJECT -e $ENV

echo "\n--- Current Resources ---"
upsun resources -p $PROJECT -e $ENV

echo "\n--- Autoscaling ---"
upsun autoscaling -p $PROJECT -e $ENV

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

CPU_USAGE=$(upsun cpu -p $PROJECT -e $ENV --start "-5 minutes" | grep -oP '\d+(?=%)' | tail -n 1)
if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
    echo "ALERT: High CPU usage: ${CPU_USAGE}%"
fi

MEM_USAGE=$(upsun memory -p $PROJECT -e $ENV --start "-5 minutes" | grep -oP '\d+(?=%)' | tail -n 1)
if [ "$MEM_USAGE" -gt "$MEMORY_THRESHOLD" ]; then
    echo "ALERT: High memory usage: ${MEM_USAGE}%"
fi

DISK_USAGE=$(upsun disk -p $PROJECT -e $ENV | grep -oP '\d+(?=%)' | tail -n 1)
if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo "ALERT: High disk usage: ${DISK_USAGE}%"
fi
```

## Resource Optimization

### Right-Sizing Process

1. **Collect metrics (2–4 weeks):**
   ```bash
   upsun metrics -p abc123 -e production --start "-30 days"
   ```

2. **Analyse patterns:** peak usage, average utilisation, growth trends, traffic patterns

3. **Calculate requirements:** peak CPU + 20% headroom; peak Memory + 20% headroom; disk with 30% free

4. **Adjust:**
   ```bash
   upsun resources:set -p abc123 -e production --size app:M
   ```

5. **Monitor after changes (1–2 weeks):**
   ```bash
   upsun metrics -p abc123 -e production
   ```

### Cost Optimisation Strategies

```bash
# Autoscale during low traffic
upsun autoscaling:set -p abc123 -e production \
  --min 1 --max 5 --target-cpu 75

# Pause dev environments
upsun environment:pause -p abc123 -e dev-testing
upsun environment:resume -p abc123 -e dev-testing

# Right-size services
upsun resources:set -p abc123 -e staging \
  --size app:S --size database:S

# Delete unused environments
upsun environment:list -p abc123 | grep Inactive
upsun environment:delete -p abc123 -e old-feature
```

## Worker Resources

```bash
upsun worker:list -p PROJECT_ID -e ENVIRONMENT_NAME
# Alias: workers

# Set worker resources
upsun resources:set -p abc123 -e production --size queue-worker:L
```

## Troubleshooting

**High CPU usage:**
- Check for infinite loops
- Review recent deployments
- Check for traffic spikes or DDoS
- Optimise database queries
- Consider scaling up

**High memory usage:**
- Check for memory leaks
- Review caching strategy
- Check uploaded file sizes
- Optimise image processing
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
- Check for subscription resource limits
