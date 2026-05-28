#!/bin/bash -e
# Redis backup script for diandantong
# Creates RDB snapshot and uploads to S3/MinIO
# Usage: ./backup_redis.sh

BACKUP_DIR="${BACKUP_DIR:-/var/backups/diandantong/redis}"
REDIS_HOST="${REDIS_HOST:-localhost}"
REDIS_PORT="${REDIS_PORT:-6379}"
REDIS_PASSWORD="${REDIS_PASSWORD:-}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
S3_BUCKET="${S3_BUCKET:-}"
S3_ENDPOINT="${S3_ENDPOINT:-}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "${BACKUP_DIR}"

echo "[$(date)] Starting Redis backup..."

# Trigger BGSAVE and wait for it to complete
if [ -n "${REDIS_PASSWORD}" ]; then
  export REDISCLI_AUTH="${REDIS_PASSWORD}"
fi

redis-cli -h "${REDIS_HOST}" -p "${REDIS_PORT}" BGSAVE

# Wait for BGSAVE to finish (timeout 120s)
TIMEOUT=120
ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
  BGSAVE_STATUS=$(redis-cli -h "${REDIS_HOST}" -p "${REDIS_PORT}" LASTSAVE)
  sleep 1
  ELAPSED=$((ELAPSED + 1))

  # Check if BGSAVE is done by comparing lastsave before/after
  NEW_LASTSAVE=$(redis-cli -h "${REDIS_HOST}" -p "${REDIS_PORT}" LASTSAVE)
  if [ "${BGSAVE_STATUS}" != "${NEW_LASTSAVE}" ] || [ $ELAPSED -gt 5 ]; then
    break
  fi
done

echo "[$(date)] BGSAVE completed"

# Copy the RDB file
if [ -f "/data/dump.rdb" ]; then
  RDB_FILE="${BACKUP_DIR}/redis_${TIMESTAMP}.rdb"
  cp /data/dump.rdb "${RDB_FILE}"
  gzip "${RDB_FILE}"
  echo "[$(date)] Redis RDB backup: ${RDB_FILE}.gz ($(du -h "${RDB_FILE}.gz" | cut -f1))"
elif command -v docker &> /dev/null; then
  # Running in Docker — copy from container
  CONTAINER_NAME="${REDIS_CONTAINER:-ddt_redis}"
  RDB_FILE="${BACKUP_DIR}/redis_${TIMESTAMP}.rdb"
  docker cp "${CONTAINER_NAME}:/data/dump.rdb" "${RDB_FILE}"
  gzip "${RDB_FILE}"
  echo "[$(date)] Redis RDB backup (docker): ${RDB_FILE}.gz"
else
  echo "[$(date)] WARNING: Could not locate Redis RDB file"
  exit 1
fi

# Upload to S3/MinIO
if [ -n "${S3_BUCKET}" ]; then
  S3_ARGS=""
  if [ -n "${S3_ENDPOINT}" ]; then
    S3_ARGS="--endpoint-url ${S3_ENDPOINT}"
  fi
  aws s3 ${S3_ARGS} cp "${BACKUP_DIR}/redis_${TIMESTAMP}.rdb.gz" \
    "s3://${S3_BUCKET}/backups/redis/redis_${TIMESTAMP}.rdb.gz"
  echo "[$(date)] S3 upload complete"
fi

# Cleanup old local backups
find "${BACKUP_DIR}" -name "redis_*.rdb.gz" -mtime +${RETENTION_DAYS} -delete

echo "[$(date)] Redis backup completed."
