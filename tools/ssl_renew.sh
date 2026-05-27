#!/bin/bash -e
# SSL certificate renewal via Let's Encrypt
# Usage: Run via cron monthly
# 0 0 1 * * /opt/diandantong/tools/ssl_renew.sh

DOMAIN="${HOST:-cy.diandantong.com}"
EMAIL="${SSL_EMAIL:-admin@diandantong.com}"
CERTBOT_DIR="/var/www/certbot"
CONFIG_DIR="./config/ssl"

mkdir -p "${CERTBOT_DIR}" "${CONFIG_DIR}"

echo "[$(date)] Renewing SSL certificate for ${DOMAIN}..."

# Use certbot in standalone mode (requires port 80)
docker run --rm \
  -v "${CONFIG_DIR}:/etc/letsencrypt" \
  -v "${CERTBOT_DIR}:/var/www/certbot" \
  -p 80:80 \
  certbot/certbot renew --quiet --agree-tos --email "${EMAIL}" --no-eff-email

# Reload nginx to pick up new certs
docker compose -f docker-compose.prod.yml exec nginx nginx -s reload

echo "[$(date)] SSL renewal completed."
