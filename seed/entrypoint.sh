#!/usr/bin/env bash
set -euo pipefail

: "${MAILCOW_HOSTNAME:=mail.local}"

NGINX_CONF_DST="/target/conf-nginx"
WEB_DST="/target/web"
SSL_DST="/target/ssl"

mkdir -p "$NGINX_CONF_DST" "$WEB_DST" "$SSL_DST"

seed_dir_if_empty() {
  local src="$1" dst="$2"
  if [ -z "$(ls -A "$dst" 2>/dev/null || true)" ]; then
    echo "Seeding $dst from $src"
    rsync -a --delete "$src"/ "$dst"/
  else
    echo "Skip seeding $dst (not empty)"
  fi
}

seed_dir_if_empty /seed/data/conf/nginx "$NGINX_CONF_DST"
seed_dir_if_empty /seed/data/web "$WEB_DST"

# snake-oil certs (so services don't crash on missing files)
if [ ! -s "$SSL_DST/cert.pem" ] || [ ! -s "$SSL_DST/key.pem" ]; then
  echo "Generating snake-oil TLS cert for CN=$MAILCOW_HOSTNAME"
  openssl req -x509 -newkey rsa:2048 -nodes \
    -keyout "$SSL_DST/key.pem" \
    -out "$SSL_DST/cert.pem" \
    -days 3650 \
    -subj "/CN=${MAILCOW_HOSTNAME}"
fi

# dhparams can be slow; use -dsaparam to be faster (still replace with proper certs later)
if [ ! -s "$SSL_DST/dhparams.pem" ]; then
  echo "Generating dhparams.pem (fast-ish)"
  openssl dhparam -dsaparam -out "$SSL_DST/dhparams.pem" 2048
fi

echo "Seed done."
exit 0
