#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BASE_DIR"

if [[ ! -f .env ]]; then
  echo "[ERROR] No existe .env. Ejecuta primero ./scripts/up.sh"
  exit 1
fi

CRON_EXPR="$(grep '^BACKUP_CRON=' .env | cut -d= -f2- | tr -d '"' || true)"
if [[ -z "${CRON_EXPR:-}" ]]; then
  CRON_EXPR="0 3 * * *"
fi

CMD="cd $BASE_DIR && /usr/bin/docker compose run --rm backup /backup.sh >> $BASE_DIR/data/logs/backup/host_cron.log 2>&1"
TMP_FILE="$(mktemp)"
crontab -l 2>/dev/null | grep -Fv "$CMD" > "$TMP_FILE" || true
echo "$CRON_EXPR $CMD" >> "$TMP_FILE"
crontab "$TMP_FILE"
rm -f "$TMP_FILE"

echo "[OK] Cron instalado en host"
echo "[INFO] Expresión: $CRON_EXPR"
echo "[INFO] Comando: $CMD"
