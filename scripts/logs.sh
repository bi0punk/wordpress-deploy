#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BASE_DIR"

SERVICE="${1:-all}"

if [[ "$SERVICE" == "backup" ]]; then
  echo "[INFO] Backup no queda residente. Revisa: data/logs/backup/"
  ls -lah data/logs/backup || true
  exit 0
fi

if [[ "$SERVICE" == "all" ]]; then
  docker compose logs -f mariadb redis wordpress nginx
else
  docker compose logs -f "$SERVICE"
fi
