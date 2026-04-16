#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BASE_DIR"

CMD="cd $BASE_DIR && /usr/bin/docker compose run --rm backup /backup.sh >> $BASE_DIR/data/logs/backup/host_cron.log 2>&1"
TMP_FILE="$(mktemp)"
crontab -l 2>/dev/null | grep -Fv "$CMD" > "$TMP_FILE" || true
crontab "$TMP_FILE"
rm -f "$TMP_FILE"

echo "[OK] Cron eliminado del host"
