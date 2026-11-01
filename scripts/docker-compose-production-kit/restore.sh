#!/usr/bin/env bash
# Restore Dujiao-Next data from a backup archive created by backup.sh.
# Usage: ./restore.sh backups/dujiao-backup-YYYYMMDD-HHMMSS.tar.gz
# This OVERWRITES config.yml, data/db and data/uploads after confirmation.
set -euo pipefail
cd "$(dirname "$0")"

ARCHIVE="${1:-}"
[ -n "$ARCHIVE" ] && [ -f "$ARCHIVE" ] || { echo "Usage: $0 <backup.tar.gz>" >&2; exit 1; }

printf "Restore from %s? Current config.yml, data/db and data/uploads will be overwritten. [y/N] " "$ARCHIVE"
read -r answer
case "$answer" in
  y|Y|yes|YES) ;;
  *) echo "Aborted."; exit 0 ;;
esac

echo "==> Stopping services ..."
docker compose down

echo "==> Extracting ${ARCHIVE} ..."
tar -xzf "$ARCHIVE"

echo "==> Starting services ..."
docker compose up -d

echo "==> Waiting for health ..."
set -a; [ -f .env ] && . ./.env; set +a
for _ in $(seq 1 60); do
  if curl -fsS -m 3 "http://127.0.0.1:${APP_PORT:-8080}/health" >/dev/null 2>&1; then
    echo "Restore complete — app is healthy."
    exit 0
  fi
  sleep 2
done
echo "App did not become healthy; check: docker compose logs -f app" >&2
exit 1
