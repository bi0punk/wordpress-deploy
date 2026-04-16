#!/usr/bin/env bash
set -euo pipefail
mkdir -p \
  data/db \
  data/wordpress \
  data/redis \
  data/backups \
  data/logs/nginx \
  data/logs/wordpress \
  data/logs/backup
chmod -R 755 data || true
echo "[OK] Directorios inicializados"
