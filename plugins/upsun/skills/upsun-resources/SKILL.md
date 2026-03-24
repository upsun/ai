---
name: upsun-resources
description: Use when the user asks to "scale resources", "resource scaling", "check metrics", "configure autoscaling", "right-size resources", "view CPU/memory/disk usage", or "performance monitoring". Provides CLI patterns for resource allocation, autoscaling, and performance metrics on Upsun.
version: 1.0.0
---

# Upsun Resources & Scaling Skill

Manage resource allocation, autoscaling, and performance metrics for Upsun environments.

## Prerequisites

```bash
upsun auth:info
```

## Key Commands

### View Resources

```bash
upsun resources:get -p PROJECT_ID -e ENV             # Current allocation
upsun resources:size:list                            # All available sizes (XS → 2XL)
upsun worker:list -p PROJECT_ID -e ENV               # Workers and their sizes
```

### Set Resources

```bash
upsun resources:set -p PROJECT_ID -e ENV             # Interactive editor
upsun resources:set -p PROJECT_ID -e ENV --size app:L
upsun resources:set -p PROJECT_ID -e ENV --size app:L --size database:M --size redis:S
upsun resources:build:get -p PROJECT_ID              # View build phase resources
upsun resources:build:set -p PROJECT_ID              # Set build phase resources
```

### Autoscaling

```bash
upsun autoscaling:get -p PROJECT_ID -e ENV           # View current config
upsun autoscaling:set -p PROJECT_ID -e ENV \
  --min 2 --max 10 --target-cpu 70                   # Enable autoscaling
upsun autoscaling:set -p PROJECT_ID -e ENV --disable # Disable autoscaling
```

### Metrics

```bash
upsun metrics:all -p PROJECT_ID -e ENV               # All metrics
upsun metrics:cpu -p PROJECT_ID -e ENV --start "-1 hour"
upsun metrics:memory -p PROJECT_ID -e ENV --start "-24 hours"
upsun metrics:disk-usage -p PROJECT_ID -e ENV
upsun metrics:disk-usage -p PROJECT_ID -e ENV --mount /app/storage
```

## Container Sizes

| Size | CPU  | Memory  |
|------|------|---------|
| XS   | 0.25 | 512 MB  |
| S    | 0.5  | 1 GB    |
| M    | 1.0  | 2 GB    |
| L    | 2.0  | 4 GB    |
| XL   | 4.0  | 8 GB    |
| 2XL  | 8.0  | 16 GB   |

## CPU Utilisation Guide

| CPU usage | Action |
|-----------|--------|
| < 50%     | Consider downsizing to save cost |
| 50–80%    | Healthy range |
| 80–95%    | Plan a scale-up |
| > 95%     | Scale up immediately |

## Scale-Up Workflow

```bash
# 1. Review current state
upsun resources -p PROJECT_ID -e production
upsun metrics -p PROJECT_ID -e production

# 2. Create backup (resource changes trigger redeploy)
upsun backup:create -p PROJECT_ID -e production

# 3. Set new size
upsun resources:set -p PROJECT_ID -e production --size app:XL

# 4. Redeploy to apply
upsun redeploy -p PROJECT_ID -e production

# 5. Confirm
upsun activity:list -p PROJECT_ID -e production -i
upsun resources -p PROJECT_ID -e production
```

## Autoscaling Best Practices

- Set `--min` to handle your steady-state load (avoid cold starts)
- Set `--max` based on your budget ceiling
- Use 70–80% CPU/memory targets — never 100%
- Test autoscaling on staging before enabling on production
- Monitor metrics for 24–48 h after enabling to validate thresholds

## Cost Optimisation

```bash
# Pause dev environments overnight
upsun environment:pause -p PROJECT_ID -e dev-testing

# Right-size staging (smaller than production)
upsun resources:set -p PROJECT_ID -e staging --size app:S --size database:S

# Scale down with autoscaling during low-traffic periods
upsun autoscaling:set -p PROJECT_ID -e production --min 1 --max 5 --target-cpu 75
```

## Reference

See [reference.md](reference.md) for:
- Daily health-check and performance alert scripts
- Right-sizing evaluation process (metrics collection → analysis → adjustment)
- Worker resource configuration
- Long-term capacity planning patterns
