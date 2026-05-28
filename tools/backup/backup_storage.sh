#!/bin/bash -e
# ActiveStorage file backup script for diandantong
# Syncs ActiveStorage files to S3/MinIO backup bucket
# Usage: ./backup_storage.sh

STORAGE_PATH="${STORAGE_PATH:-/rails/storage}"
S3_BUCKET="${S3_BUCKET:-}"
S3_ENDPOINT="${S3_ENDPOINT:-}"
BACKUP_PREFIX="${BACKUP_PREFIX:-backups/activestorage}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

if [ -z "${S3_BUCKET}" ]; then
  echo "[$(date)] ERROR: S3_BUCKET not set. ActiveStorage backup requires S3/MinIO."
  exit 1
fi

S3_ARGS=""
if [ -n "${S3_ENDPOINT}" ]; then
  S3_ARGS="--endpoint-url ${S3_ENDPOINT}"
fi

echo "[$(date)] Starting ActiveStorage backup..."

# Sync local storage to backup S3 bucket
if [ -d "${STORAGE_PATH}" ]; then
  aws s3 ${S3_ARGS} sync "${STORAGE_PATH}/" \
    "s3://${S3_BUCKET}/${BACKUP_PREFIX}/" \
    --storage-class STANDARD_IA \
    --no-progress
  echo "[$(date)] ActiveStorage sync to S3 complete"
else
  # If production already uses S3 for ActiveStorage, do S3-to-S3 backup
  SOURCE_BUCKET="${ACTIVE_STORAGE_BUCKET:-diandantong-production}"
  echo "[$(date)] Syncing S3 bucket ${SOURCE_BUCKET} to backup..."
  aws s3 ${S3_ARGS} sync "s3://${SOURCE_BUCKET}/" \
    "s3://${S3_BUCKET}/${BACKUP_PREFIX}/" \
    --storage-class STANDARD_IA \
    --no-progress
  echo "[$(date)] S3-to-S3 backup complete"
fi

# Verify backup by checking file count
FILE_COUNT=$(aws s3 ${S3_ARGS} ls "s3://${S3_BUCKET}/${BACKUP_PREFIX}/" --recursive | wc -l)
echo "[$(date)] ActiveStorage backup completed. ${FILE_COUNT} files synced."
