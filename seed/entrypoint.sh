# seed/entrypoint.sh
# Seeds nginx templates + web UI into mounted volumes, and creates placeholder TLS if missing.
# Assumes you mount:
#   - <nginx-conf-vol>:/target/conf-nginx
#   - <web-vol>:/target/web
#   - <ssl-vol>:/target/ssl

set -euo pipefail

SEED_NGINX_SRC="${SEED_NGINX_SRC:-/seed/conf-nginx}"
SEED_WEB_SRC="${SEED_WEB_SRC:-/seed/web}"
TARGET_NGINX="${TARGET_NGINX:-/target/conf-nginx}"
TARGET_WEB="${TARGET_WEB:-/target/web}"
TARGET_SSL="${TARGET_SSL:-/target/ssl}"

MAILCOW_HOSTNAME="${MAILCOW_HOSTNAME:-mail.local}"

mkdir -p "$TARGET_NGINX" "$TARGET_WEB" "$TARGET_SSL"

# 1) Seed nginx templates if empty (idempotent)
if [ -z "$(ls -A "$TARGET_NGINX" 2>/dev/null || true)" ]; then
  echo "[seed] Seeding nginx conf..."
  cp -a "$SEED_NGINX_SRC/." "$TARGET_NGINX/"
else
  echo "[seed] nginx conf already present, skipping"
fi

# 2) Seed web UI if empty (idempotent)
if [ -z "$(ls -A "$TARGET_WEB" 2>/dev/null || true)" ]; then
  echo "[seed] Seeding web..."
  cp -a "$SEED_WEB_SRC/." "$TARGET_WEB/"
else
  echo "[seed] web already present, skipping"
fi

# 3) Ensure TLS exists (placeholder so nginx/postfix/dovecot can start)
if [ ! -s "$TARGET_SSL/cert.pem" ] || [ ! -s "$TARGET_SSL/key.pem" ]; then
  echo "[seed] Generating self-signed TLS for CN=${MAILCOW_HOSTNAME} ..."
  openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
    -subj "/CN=${MAILCOW_HOSTNAME}" \
    -keyout "$TARGET_SSL/key.pem" -out "$TARGET_SSL/cert.pem"
fi

if [ ! -s "$TARGET_SSL/dhparams.pem" ]; then
  echo "[seed] Generating dhparams..."
  openssl dhparam -out "$TARGET_SSL/dhparams.pem" 2048
fi

chmod 0644 "$TARGET_SSL/cert.pem" "$TARGET_SSL/dhparams.pem" || true
chmod 0600 "$TARGET_SSL/key.pem" || true

echo "[seed] Done. Keeping container alive."
exec tail -f /dev/null
