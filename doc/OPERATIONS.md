# Operations Guide — diandantong (点单通)

Production operations documentation for monitoring, alerting, logging, and backup/recovery.

## Table of Contents

1. [Monitoring](#1-monitoring)
2. [Alerting](#2-alerting)
3. [Logging](#3-logging)
4. [Backup & Recovery](#4-backup--recovery)
5. [Runbooks](#5-runbooks)

---

## 1. Monitoring

### Access Points

| Service | URL | Credentials |
|---------|-----|-------------|
| Grafana | `http://<server>:3001` | `admin` / see `GRAFANA_ADMIN_PASSWORD` |
| Prometheus | `http://<server>:9090` | — |
| Alertmanager | `http://<server>:9093` | — |

### Dashboards

| Dashboard | UID | Description |
|-----------|-----|-------------|
| Rails Overview | `rails-overview` | Request rate, response times, Puma workers, memory, DB pool |
| Sidekiq Overview | `sidekiq-overview` | Job throughput, queue sizes, failures, retry/dead sets |
| PostgreSQL Overview | `postgresql-overview` | Connections, TPS, cache hit ratio, dead tuples, DB size |
| Redis Overview | `redis-overview` | Memory, commands/s, hit rate, keyspace |
| Infrastructure Overview | `infrastructure-overview` | Nginx, service health, access/error logs |

### Launching Monitoring Stack

```bash
# Production (Docker Compose)
docker compose -f docker-compose.prod.yml -f docker-compose.monitoring.yml up -d

# Kamal 2
kamal accessories start prometheus
kamal accessories start grafana
kamal accessories start loki
```

### Key Metrics to Watch

- **Request rate**: `sum(rate(http_requests_total[5m]))`
- **Error rate**: `sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))`
- **P95 latency**: `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))`
- **Sidekiq queue backlog**: `sidekiq_queue_size{queue="default"}`
- **DB connections**: `pg_stat_activity_count`
- **Redis memory**: `redis_memory_used_bytes / redis_memory_max_bytes`

---

## 2. Alerting

### Alert Severity Levels

| Level | Response Time | Notification |
|-------|--------------|--------------|
| **Critical** | Immediate (< 15 min) | Webhook → oncall |
| **Warning** | Same day | Webhook → team channel |

### Active Alerts

| Alert | Severity | Condition | Description |
|-------|----------|-----------|-------------|
| `HighErrorRate` | Critical | 5xx > 5% for 2m | Application error rate spike |
| `HighResponseTime` | Warning | P95 > 5s for 5m | Response latency degradation |
| `SidekiqQueueBacklog` | Warning | default queue > 1000 for 5m | Jobs accumulating |
| `SidekiqQueueBacklogCritical` | Critical | critical queue > 500 for 2m | Critical jobs delayed |
| `SidekiqFailedJobs` | Critical | failed > 50 for 5m | Worker failures |
| `SidekiqWorkersNotProcessing` | Critical | 0 workers for 5m | Sidekiq down |
| `DatabaseConnectionPoolExhausted` | Critical | available < 2 for 1m | Connection leak |
| `PostgresConnectionsHigh` | Warning | connections > 180 for 5m | Connection buildup |
| `RedisMemoryHigh` | Warning | memory > 90% for 5m | Cache eviction pressure |
| `DiskSpaceLow` | Critical | disk < 10% for 5m | Imminent disk full |
| `DiskSpaceWarning` | Warning | disk < 20% for 30m | Disk filling up |

### Configuring Notification Channels

Edit `tools/monitoring/alertmanager.yml` to add email, WeChat, or DingTalk receivers:

```yaml
receivers:
  - name: "critical"
    email_configs:
      - to: "ops@diandantong.com"
        from: "alerts@diandantong.com"
        smarthost: "smtp.exmail.qq.com:25"
```

---

## 3. Logging

### Log Sources

| Source | Format | Promtail Job |
|--------|--------|-------------|
| Rails app | JSON (production) | `rails` |
| Sidekiq | Text | `sidekiq` |
| Nginx access | Combined format | `nginx_access` |
| Nginx error | Standard | `nginx_error` |

### Querying Logs (Grafana Explore)

```logql
# Rails errors in last hour
{job="rails"} |= "level=error"

# Sidekiq exceptions
{job="sidekiq"} |= "exception" | json

# Nginx 5xx responses
{job="nginx_access"} | logfmt | status >= 500

# Request tracing by request_id
{job="rails"} |= "request_id=abc123"
```

### Structured JSON Log Format

Rails logs in production use JSON format:

```json
{
  "timestamp": "2026-05-29T10:30:00.123456+08:00",
  "level": "INFO",
  "environment": "production",
  "message": "Completed 200 OK in 45ms",
  "request_id": "abc123",
  "method": "GET",
  "path": "/api/v1/orders",
  "status": 200,
  "duration": 0.045
}
```

---

## 4. Backup & Recovery

### Backup Schedule

| Component | Schedule | Retention | Storage |
|-----------|----------|-----------|---------|
| PostgreSQL | Daily at 02:00 | 30 days | Local + S3/MinIO |
| Redis | Daily at 02:00 | 30 days | Local + S3/MinIO |
| ActiveStorage | Daily at 02:00 | Continuous sync | S3/MinIO |

### Running Backups Manually

```bash
# Via rake task (recommended)
docker compose -f docker-compose.prod.yml exec app bundle exec rake backup:postgres
docker compose -f docker-compose.prod.yml exec app bundle exec rake backup:redis
docker compose -f docker-compose.prod.yml exec app bundle exec rake backup:storage
docker compose -f docker-compose.prod.yml exec app bundle exec rake backup:all

# Via shell scripts directly
docker compose -f docker-compose.prod.yml exec backup bash /rails/tools/backup/backup.sh
docker compose -f docker-compose.prod.yml exec backup bash /rails/tools/backup/backup_redis.sh
docker compose -f docker-compose.prod.yml exec backup bash /rails/tools/backup/backup_storage.sh
```

### Verify Backup Integrity

```bash
docker compose -f docker-compose.prod.yml exec app bundle exec rake backup:verify
```

### Recovery Procedures

#### PostgreSQL Recovery

```bash
# 1. Stop application services
docker compose -f docker-compose.prod.yml stop app sidekiq

# 2. List available backups
ls -lt /var/backups/diandantong/*.dump

# 3. Run restore
docker compose -f docker-compose.prod.yml exec backup bash /rails/tools/backup/restore.sh --postgres /var/backups/diandantong/diandantong_production_20260529_020000.dump

# 4. Run migrations
docker compose -f docker-compose.prod.yml exec app bundle exec rails db:migrate

# 5. Restart services
docker compose -f docker-compose.prod.yml start app sidekiq
```

#### Redis Recovery

```bash
# 1. Stop Redis
docker compose -f docker-compose.prod.yml stop redis

# 2. Run restore
docker compose -f docker-compose.prod.yml exec backup bash /rails/tools/backup/restore.sh --redis /var/backups/diandantong/redis/redis_20260529_020000.rdb.gz

# 3. Start Redis
docker compose -f docker-compose.prod.yml start redis
```

#### ActiveStorage Recovery

```bash
docker compose -f docker-compose.prod.yml exec backup bash /rails/tools/backup/restore.sh --storage
```

#### Full System Recovery

```bash
# Restore everything from a backup directory
docker compose -f docker-compose.prod.yml exec backup bash /rails/tools/backup/restore.sh --all /var/backups/diandantong
```

---

## 5. Runbooks

### High Error Rate (>5% 5xx)

1. Check Grafana → Rails Overview → Recent Errors panel
2. Query Loki: `{job="rails"} |= "level=error"`
3. Identify affected endpoints (Top Slow Endpoints table)
4. Check for recent deployments: `git log --oneline -10`
5. If caused by deployment, consider rollback: `kamal rollback`
6. Check database connectivity: `pg_isready -h $DB_HOST`

### Sidekiq Queue Backlog

1. Check Sidekiq Overview dashboard for queue sizes
2. Check for failed/retry jobs in Sidekiq Web UI
3. If workers stuck, restart Sidekiq: `docker compose restart sidekiq`
4. Check if specific job class is failing: Loki query `{job="sidekiq"} |= "error"`
5. Scale Sidekiq workers if needed (increase concurrency in sidekiq.yml)

### Database Connection Pool Exhaustion

1. Check PostgreSQL Overview → Connections panel
2. Identify long-running queries: `SELECT * FROM pg_stat_activity WHERE state = 'active' ORDER BY query_start;`
3. Kill stuck queries if needed: `SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE state = 'active' AND query_start < now() - interval '5 minutes';`
4. Restart app to reset pool: `docker compose restart app`

### Redis Memory Full

1. Check Redis Overview → Memory Usage
2. Identify large keys: `redis-cli --bigkeys`
3. If eviction policy not working, check TTL policies on keys
4. Consider increasing `maxmemory` in Redis config
5. Restart Redis if unresponsive: `docker compose restart redis`

### Disk Space Low

1. Check largest directories: `du -h --max-depth=2 / | sort -rh | head -20`
2. Clean old Docker images: `docker image prune -a --filter "until=168h"`
3. Clean old logs: `find /var/log -name "*.log" -mtime +30 -delete`
4. Verify backup integrity before deleting old backups
5. If PostgreSQL, run VACUUM: `psql -c "VACUUM FULL;"`

### Backup Failure

1. Check backup container logs: `docker compose logs backup`
2. Verify S3/MinIO credentials and connectivity
3. Check disk space on backup volume
4. Run backup manually to diagnose: `docker compose exec backup bash -c "cd /rails && bundle exec rake backup:postgres"`
5. If S3 upload fails, check `BACKUP_S3_BUCKET` and `BACKUP_S3_ENDPOINT` env vars
