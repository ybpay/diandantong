#!/bin/bash -e
# Restore script for diandantong PostgreSQL backup
# Usage: ./restore.sh <backup_file.dump>

DUMP_FILE="${1:?Usage: restore.sh <backup_file.dump>}"
DB_NAME="${DB_NAME:-diandantong_production}"
DB_USER="${DB_USER:-diandantong}"
DB_HOST="${DB_HOST:-localhost}"

if [ ! -f "${DUMP_FILE}" ]; then
  echo "Error: File not found: ${DUMP_FILE}"
  exit 1
fi

echo "WARNING: This will drop and recreate the database ${DB_NAME}!"
read -p "Continue? (yes/no): " CONFIRM

if [ "${CONFIRM}" != "yes" ]; then
  echo "Aborted."
  exit 1
fi

echo "[$(date)] Stopping application..."
# docker compose -f docker-compose.prod.yml stop app sidekiq

echo "[$(date)] Dropping and recreating database..."
dropdb -h "${DB_HOST}" -U "${DB_USER}" --if-exists "${DB_NAME}"
createdb -h "${DB_HOST}" -U "${DB_USER}" "${DB_NAME}"

echo "[$(date)] Restoring from ${DUMP_FILE}..."
pg_restore \
  -h "${DB_HOST}" \
  -U "${DB_USER}" \
  -d "${DB_NAME}" \
  --verbose \
  --no-owner \
  --no-acl \
  "${DUMP_FILE}"

echo "[$(date)] Running pending migrations..."
# docker compose -f docker-compose.prod.yml run --rm app bundle exec rails db:migrate

echo "[$(date)] Restore completed."
echo "[$(date)] Start the application with: docker compose -f docker-compose.prod.yml up -d"
