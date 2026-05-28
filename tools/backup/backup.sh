#!/bin/bash -e
# PostgreSQL backup script for diandantong
# Supports: local filesystem, S3, MinIO
# Usage: ./backup.sh (run via cron or sidekiq scheduler)

BACKUP_DIR="${BACKUP_DIR:-/var/backups/diandantong}"
DB_NAME="${DB_NAME:-diandantong_production}"
DB_USER="${DB_USER:-diandantong}"
DB_HOST="${DB_HOST:-localhost}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
S3_BUCKET="${S3_BUCKET:-}"
S3_ENDPOINT="${S3_ENDPOINT:-}"  # MinIO endpoint if using MinIO
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "${BACKUP_DIR}"

echo "[$(date)] Starting PostgreSQL backup of ${DB_NAME}..."

# Create custom format backup (parallel restore capable)
CUSTOM_FILE="${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.dump"
pg_dump \
  -h "${DB_HOST}" \
  -U "${DB_USER}" \
  -d "${DB_NAME}" \
  --format=custom \
  --compress=6 \
  --verbose \
  -f "${CUSTOM_FILE}"

# Create plain SQL backup
SQL_FILE="${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.sql.gz"
pg_dump \
  -h "${DB_HOST}" \
  -U "${DB_USER}" \
  -d "${DB_NAME}" \
  --format=plain \
  --no-owner \
  --no-acl \
  | gzip > "${SQL_FILE}"

echo "[$(date)] PostgreSQL backup created:"
echo "  Custom: ${CUSTOM_FILE} ($(du -h "${CUSTOM_FILE}" | cut -f1))"
echo "  SQL:    ${SQL_FILE} ($(du -h "${SQL_FILE}" | cut -f1))"

# Upload to S3/MinIO if configured
if [ -n "${S3_BUCKET}" ]; then
  S3_ARGS=""
  if [ -n "${S3_ENDPOINT}" ]; then
    S3_ARGS="--endpoint-url ${S3_ENDPOINT}"
  fi

  echo "[$(date)] Uploading to S3/MinIO..."
  aws s3 ${S3_ARGS} cp "${CUSTOM_FILE}" \
    "s3://${S3_BUCKET}/backups/postgres/$(basename "${CUSTOM_FILE}")"
  aws s3 ${S3_ARGS} cp "${SQL_FILE}" \
    "s3://${S3_BUCKET}/backups/postgres/$(basename "${SQL_FILE}")"
  echo "[$(date)] S3 upload complete"
fi

# Cleanup old local backups
find "${BACKUP_DIR}" -name "${DB_NAME}_*.dump" -mtime +${RETENTION_DAYS} -delete
find "${BACKUP_DIR}" -name "${DB_NAME}_*.sql.gz" -mtime +${RETENTION_DAYS} -delete

# Cleanup old S3 backups (if configured)
if [ -n "${S3_BUCKET}" ]; then
  S3_ARGS=""
  if [ -n "${S3_ENDPOINT}" ]; then
    S3_ARGS="--endpoint-url ${S3_ENDPOINT}"
  fi
  CUT_DATE=$(date -d "-${RETENTION_DAYS} days" +%Y%m%d 2>/dev/null || date -v-${RETENTION_DAYS}d +%Y%m%d)
  aws s3 ${S3_ARGS} ls "s3://${S3_BUCKET}/backups/postgres/" | \
    awk "{print \$4}" | \
    while read -r fname; do
      FILE_DATE=$(echo "${fname}" | grep -oP '\d{8}' | head -1)
      if [ -n "${FILE_DATE}" ] && [ "${FILE_DATE}" -lt "${CUT_DATE}" ]; then
        aws s3 ${S3_ARGS} rm "s3://${S3_BUCKET}/backups/postgres/${fname}"
        echo "  Deleted old S3 backup: ${fname}"
      fi
    done
fi

echo "[$(date)] PostgreSQL backup completed."
