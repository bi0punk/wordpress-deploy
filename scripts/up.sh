#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BASE_DIR"

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "[INFO] No existía .env. Se creó desde .env.example"
fi

./scripts/init_dirs.sh
if [[ -f data/wordpress/wp-config.php ]]; then
  echo "[WARN] Existe data/wordpress/wp-config.php. Si vienes de una versión anterior y falla, ejecuta: ./scripts/reset.sh"
fi
docker compose config >/dev/null
docker compose up --build -d mariadb redis wordpress nginx

echo "[OK] Stack levantado"
echo "[INFO] Accede a: http://localhost:8080"
echo "[INFO] Backup manual: ./scripts/backup_now.sh"
echo "[INFO] Backup automático host: ./scripts/install_host_cron.sh"
