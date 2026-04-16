#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BASE_DIR"

echo "[WARN] Esto detendrá y borrará el stack local y la data persistente."
read -r -p "Escribe SI para continuar: " RESP
if [[ "$RESP" != "SI" ]]; then
  echo "[INFO] Cancelado"
  exit 0
fi

docker compose down -v --remove-orphans
rm -rf data/db/* data/wordpress/* data/redis/* data/backups/* data/logs/nginx/* data/logs/wordpress/* data/logs/backup/*
echo "[OK] Reset completo"
