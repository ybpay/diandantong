#!/bin/bash -e
# PostgreSQL backup script for diandantong
# Usage: ./backup.sh (run via cron daily)

BACKUP_DIR="${BACKUP_DIR:-/var/backups/diandantong}"
DB_NAME="${DB_NAME:-diandantong_production}"
DB_USER="${DB_USER:-diandantong}"
DB_HOST="${DB_HOST:-localhost}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
S3_BUCKET="${S3_BUCKET:-}"  # Optional S3 upload

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.sql.gz"

mkdir -p "${BACKUP_DIR}"

echo "[$(date)] Starting backup of ${DB_NAME}..."

# Create pg_dump with custom format for parallel restore
pg_dump \
  -h "${DB_HOST}" \
  -U "${DB_USER}" \
  -d "${DB_NAME}" \
  --format=custom \
  --compress=6 \
  --verbose \
  -f "${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.dump"

# Also create plain SQL backup
pg_dump \
  -h "${DB_HOST}" \
  -U "${DB_USER}" \
  -d "${DB_NAME}" \
  --format=plain \
  --no-owner \
  --no-acl \
  | gzip > "${BACKUP_FILE}"

echo "[$(date)] Backup created: ${BACKUP_FILE}"
echo "[$(date)] Custom format: ${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.dump"

# Upload to S3 if configured
if [ -n "${S3_BUCKET}" ]; then
  echo "[$(date)] Uploading to S3..."
  aws s3 cp "${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.dump" \
    "s3://${S3_BUCKET}/backups/postgres/${DB_NAME}_${TIMESTAMP}.dump"
  aws s3 cp "${BACKUP_FILE}" \
    "s3://${S3_BUCKET}/backups/postgres/$(basename ${BACKUP_FILE})"
  echo "[$(date)] S3 upload complete"
fi

# Cleanup old backups
find "${BACKUP_DIR}" -name "*.dump" -mtime +${RETENTION_DAYS} -delete
find "${BACKUP_DIR}" -name "*.sql.gz" -mtime +${RETENTION_DAYS} -delete

echo "[$(date)] Backup completed. Cleaned up backups older than ${RETENTION_DAYS} days."
