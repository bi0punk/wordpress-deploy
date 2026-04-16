#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BASE_DIR"

docker compose ps mariadb redis wordpress nginx

echo
echo "[INFO] El servicio backup no queda corriendo."
echo "[INFO] Úsalo con: ./scripts/backup_now.sh"
