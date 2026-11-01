#!/usr/bin/env bash
# Backup Dujiao-Next data (SQLite db + uploads + config.yml) into backups/.
# By default the app is stopped briefly for a consistent SQLite snapshot.
# Use --live to back up without stopping (faster, small consistency risk).
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p backups
TS="$(date +%Y%m%d-%H%M%S)"
OUT="backups/dujiao-backup-${TS}.tar.gz"
LIVE=0
[ "${1:-}" = "--live" ] && LIVE=1

restart_needed=0
if [ "$LIVE" != "1" ] && docker compose ps --status running app 2>/dev/null | grep -q dujiao-next; then
  echo "==> Stopping app for a consistent snapshot ..."
  docker compose stop app
  restart_needed=1
fi

echo "==> Writing ${OUT} ..."
tar -czf "$OUT" config.yml data/db data/uploads

if [ "$restart_needed" = "1" ]; then
  echo "==> Restarting app ..."
  docker compose up -d app
fi

echo "Done: ${OUT} ($(du -h "$OUT" | cut -f1))"
echo "Keep a copy off this machine. Restore with: ./restore.sh ${OUT}"
