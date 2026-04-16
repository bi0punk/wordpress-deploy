#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP="$(date +%F_%H-%M-%S)"
BACKUP_DIR="/backups"
LOG_DIR="/logs"
DB_FILE="${BACKUP_DIR}/db_${TIMESTAMP}.sql.gz"
WP_FILE="${BACKUP_DIR}/wp_content_${TIMESTAMP}.tar.gz"
LOG_FILE="${LOG_DIR}/backup_${TIMESTAMP}.log"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

{
  echo "[INFO] Inicio backup: $(date)"

  echo "[INFO] Verificando conectividad a MariaDB..."
  mariadb-admin ping -h mariadb -u root "-p${MYSQL_ROOT_PASSWORD}" --silent

  echo "[INFO] Dump base de datos..."
  mariadb-dump \
    -h mariadb \
    -u root \
    "-p${MYSQL_ROOT_PASSWORD}" \
    --single-transaction \
    --quick \
    --lock-tables=false \
    "${MYSQL_DATABASE}" | gzip > "$DB_FILE"

  if [[ -d /var/www/html/wp-content ]]; then
    echo "[INFO] Backup wp-content..."
    tar -czf "$WP_FILE" -C /var/www/html wp-content
  else
    echo "[WARN] No existe /var/www/html/wp-content todavía; se omite backup de archivos."
  fi

  echo "[INFO] Eliminando backups > 7 días..."
  find "$BACKUP_DIR" -type f -mtime +7 -delete

  echo "[OK] Backup completado: $(date)"
} >> "$LOG_FILE" 2>&1

echo "[OK] Backup finalizado. Log: $LOG_FILE"
