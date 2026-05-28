#!/bin/bash -e
# Restore script for diandantong — PostgreSQL, Redis, ActiveStorage
# Usage: ./restore.sh [--postgres <file>] [--redis <file>] [--storage] [--all <dir>]

set -o pipefail

DB_NAME="${DB_NAME:-diandantong_production}"
DB_USER="${DB_USER:-diandantong}"
DB_HOST="${DB_HOST:-localhost}"
REDIS_HOST="${REDIS_HOST:-localhost}"
REDIS_PORT="${REDIS_PORT:-6379}"
S3_BUCKET="${S3_BUCKET:-}"
S3_ENDPOINT="${S3_ENDPOINT:-}"

# Parse arguments
RESTORE_POSTGRES=""
RESTORE_REDIS=""
RESTORE_STORAGE=false
RESTORE_ALL=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --postgres)
      RESTORE_POSTGRES="$2"; shift 2 ;;
    --redis)
      RESTORE_REDIS="$2"; shift 2 ;;
    --storage)
      RESTORE_STORAGE=true; shift ;;
    --all)
      RESTORE_ALL="$2"; shift 2 ;;
    --help|-h)
      echo "Usage: restore.sh [--postgres <dump_file>] [--redis <rdb_file>] [--storage] [--all <backup_dir>]"
      echo ""
      echo "  --postgres <file>  Restore PostgreSQL from .dump or .sql.gz file"
      echo "  --redis <file>     Restore Redis from .rdb.gz file"
      echo "  --storage          Restore ActiveStorage files from S3 backup"
      echo "  --all <dir>        Restore all from a backup directory"
      exit 0 ;;
    *)
      echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Handle --all mode
if [ -n "${RESTORE_ALL}" ]; then
  echo "[$(date)] Full restore from ${RESTORE_ALL}..."
  LATEST_PG=$(ls -t "${RESTORE_ALL}"/*.dump 2>/dev/null | head -1)
  LATEST_REDIS=$(ls -t "${RESTORE_ALL}"/redis_*.rdb.gz 2>/dev/null | head -1)
  [ -n "${LATEST_PG}" ] && RESTORE_POSTGRES="${LATEST_PG}"
  [ -n "${LATEST_REDIS}" ] && RESTORE_REDIS="${LATEST_REDIS}"
  RESTORE_STORAGE=true
fi

# === PostgreSQL Restore ===
if [ -n "${RESTORE_POSTGRES}" ]; then
  if [ ! -f "${RESTORE_POSTGRES}" ]; then
    echo "ERROR: File not found: ${RESTORE_POSTGRES}"
    exit 1
  fi

  echo "=========================================="
  echo "WARNING: This will drop and recreate ${DB_NAME}!"
  echo "File: ${RESTORE_POSTGRES}"
  echo "=========================================="
  read -p "Continue with PostgreSQL restore? (yes/no): " CONFIRM
  [ "${CONFIRM}" != "yes" ] && echo "Aborted." && exit 1

  echo "[$(date)] Stopping application..."
  # Uncomment for Docker deployment:
  # docker compose -f docker-compose.prod.yml stop app sidekiq

  echo "[$(date)] Dropping and recreating database..."
  dropdb -h "${DB_HOST}" -U "${DB_USER}" --if-exists "${DB_NAME}"
  createdb -h "${DB_HOST}" -U "${DB_USER}" "${DB_NAME}"

  if [[ "${RESTORE_POSTGRES}" == *.dump ]]; then
    echo "[$(date)] Restoring from custom format..."
    pg_restore \
      -h "${DB_HOST}" \
      -U "${DB_USER}" \
      -d "${DB_NAME}" \
      --verbose \
      --no-owner \
      --no-acl \
      "${RESTORE_POSTGRES}"
  elif [[ "${RESTORE_POSTGRES}" == *.sql.gz ]]; then
    echo "[$(date)] Restoring from SQL dump..."
    gunzip -c "${RESTORE_POSTGRES}" | \
      psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}"
  fi

  echo "[$(date)] Running pending migrations..."
  # Uncomment for Docker deployment:
  # docker compose -f docker-compose.prod.yml run --rm app bundle exec rails db:migrate

  echo "[$(date)] PostgreSQL restore completed."
fi

# === Redis Restore ===
if [ -n "${RESTORE_REDIS}" ]; then
  if [ ! -f "${RESTORE_REDIS}" ]; then
    echo "ERROR: File not found: ${RESTORE_REDIS}"
    exit 1
  fi

  echo "=========================================="
  echo "WARNING: This will replace Redis data!"
  echo "File: ${RESTORE_REDIS}"
  echo "=========================================="
  read -p "Continue with Redis restore? (yes/no): " CONFIRM
  [ "${CONFIRM}" != "yes" ] && echo "Aborted." && exit 1

  echo "[$(date)] Stopping Redis..."
  # Uncomment for Docker deployment:
  # docker compose -f docker-compose.prod.yml stop redis

  echo "[$(date)] Decompressing RDB file..."
  gunzip -c "${RESTORE_REDIS}" > /data/dump.rdb

  echo "[$(date)] Starting Redis..."
  # Uncomment for Docker deployment:
  # docker compose -f docker-compose.prod.yml start redis

  echo "[$(date)] Redis restore completed."
fi

# === ActiveStorage Restore ===
if [ "${RESTORE_STORAGE}" = true ]; then
  S3_ARGS=""
  if [ -n "${S3_ENDPOINT}" ]; then
    S3_ARGS="--endpoint-url ${S3_ENDPOINT}"
  fi

  if [ -z "${S3_BUCKET}" ]; then
    echo "[$(date)] ERROR: S3_BUCKET not set for storage restore."
    exit 1
  fi

  echo "=========================================="
  echo "WARNING: This will overwrite ActiveStorage files!"
  echo "=========================================="
  read -p "Continue with storage restore? (yes/no): " CONFIRM
  [ "${CONFIRM}" != "yes" ] && echo "Aborted." && exit 1

  STORAGE_PATH="${STORAGE_PATH:-/rails/storage}"
  aws s3 ${S3_ARGS} sync "s3://${S3_BUCKET}/backups/activestorage/" \
    "${STORAGE_PATH}/"

  echo "[$(date)] ActiveStorage restore completed."
fi

echo "[$(date)] All requested restores completed."
echo "[$(date)] Start the application with: docker compose -f docker-compose.prod.yml up -d"
