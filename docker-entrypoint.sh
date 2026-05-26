#!/bin/bash
set -e

# Wait for MySQL to be ready
if [ "$WAIT_FOR_MYSQL" = "true" ]; then
    echo "Waiting for MySQL at ${MYSQL_HOST:-mysql}:${MYSQL_PORT:-3306}..."
    until nc -z ${MYSQL_HOST:-mysql} ${MYSQL_PORT:-3306} 2>/dev/null; do
        echo "MySQL is unavailable - sleeping..."
        sleep 2
    done
    echo "MySQL is up!"
fi

# Wait for Redis to be ready
if [ "$WAIT_FOR_REDIS" = "true" ]; then
    echo "Waiting for Redis at ${REDIS_HOST:-redis}:${REDIS_PORT:-6379}..."
    until nc -z ${REDIS_HOST:-redis} ${REDIS_PORT:-6379} 2>/dev/null; do
        echo "Redis is unavailable - sleeping..."
        sleep 2
    done
    echo "Redis is up!"
fi

# Generate config files from environment if not mounted
if [ ! -f config/database.yml ]; then
    cat > config/database.yml <<EOF
${DATABASE_YML_CONTENT}
EOF
fi

if [ ! -f config/redis_client.yml ]; then
    cat > config/redis_client.yml <<EOF
defaults: &defaults
  host: ${REDIS_HOST:-redis}
  port: ${REDIS_PORT:-6379}
  db: ${REDIS_DB:-11}

development:
  <<: *defaults

production:
  <<: *defaults
EOF
fi

if [ ! -f config/secrets.yml ]; then
    cat > config/secrets.yml <<EOF
production:
  secret_key_base: ${SECRET_KEY_BASE:-$(openssl rand -hex 64)}
EOF
fi

# Run database migrations if requested
if [ "$RUN_MIGRATIONS" = "true" ]; then
    echo "Running database migrations..."
    bundle exec rake db:migrate || echo "Migration failed or no pending migrations"
fi

exec "$@"
