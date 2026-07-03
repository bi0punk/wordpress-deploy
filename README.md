# wordpress-deploy

![CI](https://github.com/bi0punk/wordpress-deploy/actions/workflows/ci.yml/badge.svg)
![License](https://img.shields.io/badge/license-MIT-blue)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ed)

Deployment production-grade de WordPress con Docker Compose: MariaDB, Redis object cache (seguro), Nginx reverse proxy y backups automatizados.

**Seguridad:** Redis requiere autenticación (`requirepass`) y **no publica puerto al host**; solo es alcanzable dentro de la red interna de Docker (`wpnet`). Nginx es el único punto de entrada expuesto (`8080:80`).

## Tabla de contenidos
- [Características](#características)
- [Stack](#stack)
- [Arquitectura](#arquitectura)
- [Requisitos previos](#requisitos-previos)
- [Instalación](#instalación)
- [Uso](#uso)
- [Configuración](#configuración)
- [Tests](#tests)
- [CI](#ci)
- [Seguridad](#seguridad)
- [Estructura de datos](#estructura-de-datos)
- [Limitaciones / roadmap](#limitaciones--roadmap)
- [Licencia](#licencia)

## Características
- WordPress listo con configuración inyectada por entorno.
- MariaDB afinado (InnoDB buffer pool, charset utf8mb4).
- Redis como object cache con password y persistencia AOF.
- Nginx como reverse proxy (único puerto publicado).
- Backups automatizados de DB + archivos de WordPress.
- Healthchecks encadenados: nginx ← wordpress ← (mariadb, redis).
- Scripts de operativa (`up`, `down`, `logs`, `backup_now`, `reset`, `status`).

## Stack
| Tecnología | Versión | Rol |
|---|---|---|
| Docker Compose | v2 | Orquestación |
| WordPress | php8.2-apache | Aplicación |
| MariaDB | 10.11 | Base de datos |
| Redis | 7-alpine | Object cache |
| Nginx | 1.27-alpine | Reverse proxy |

## Arquitectura
```
        :8080 (host)
           │
        Nginx ── (ro) ── /var/www/html
           │
        WordPress (php8.2-apache)
        /└──────────┴\
   MariaDB        Redis (object cache)
```
Todo en la red bridge `wpnet`; solo Nginx publica puerto al host.

## Requisitos previos
- Docker Engine 24+
- Docker Compose v2
- ~1 GB de RAM libre (WordPress + MariaDB)

## Instalación
```bash
git clone https://github.com/bi0punk/wordpress-deploy.git
cd wordpress-deploy
cp .env.example .env
# Editá .env con tus passwords reales:
#   $EDITOR .env
```

## Uso
```bash
# Inicializar directorios de datos (permisos)
./scripts/init_dirs.sh

# Levantar todo
./scripts/up.sh          # o: docker compose up -d

# Ver estado
./scripts/status.sh

# Ver logs
./scripts/logs.sh

# Backup manual
./scripts/backup_now.sh

# Bajar
./scripts/down.sh

# Reset completo (¡borra datos!)
./scripts/reset.sh
```

Acceder a `http://localhost:8080` y completar el wizard de WordPress.

### Scripts disponibles
| Script | Acción |
|---|---|
| `init_dirs.sh` | Crea `data/` con permisos correctos |
| `up.sh` / `down.sh` | Levanta / baja el stack |
| `logs.sh` | Tails de logs de todos los servicios |
| `status.sh` | `docker compose ps` formateado |
| `backup_now.sh` | Ejecuta backup inmediato (`docker compose run --rm backup /backup.sh`) |
| `install_host_cron.sh` / `uninstall_host_cron.sh` | Instala/desinstala cron de backup en el host |
| `reset.sh` | Borra volúmenes y datos (peligroso) |

## Configuración
Variables en `.env` (ver `.env.example`):

| Variable | Default | Descripción |
|---|---|---|
| `TZ` | `America/Santiago` | Zona horaria de todos los servicios |
| `MYSQL_DATABASE` | `wordpress` | Nombre de la DB |
| `MYSQL_USER` | `wpuser` | Usuario de la DB para WP |
| `MYSQL_PASSWORD` | — | Password del usuario WP |
| `MYSQL_ROOT_PASSWORD` | — | Password root de MariaDB |
| `WP_HOME_URL` | `http://localhost:8080` | URL pública (usada por `WP_HOME`/`WP_SITEURL`) |
| `WORDPRESS_TABLE_PREFIX` | `wp_` | Prefijo de tablas |
| `REDIS_PASSWORD` | — | Password de Redis (object cache) |

## Tests
Smoke tests que validan sintaxis del compose, presencia de `.env.example` y reglas de seguridad de Redis (sin `bind 127.0.0.1`, healthcheck autenticado):

```bash
uv venv && source .venv/bin/activate
uv pip install pytest pyyaml
pytest -q
```

## CI
`.github/workflows/ci.yml` valida:
- `docker compose config` parsea sin errores.
- Shellcheck sobre `scripts/*.sh`.
- Smoke tests de `tests/`.

## Seguridad
- **Redis:** `requirepass` obligatorio + red interna `wpnet` (sin `ports:` publicado al host). El `bind 0.0.0.0` es intencional y seguro: dentro del contenedor debe escuchar en todas las interfaces para que WordPress (otro contenedor) lo alcance por `redis:6379`; la aislación del host la da Docker, no el `bind`.
- **MariaDB:** sin puerto publicado; solo accesible en `wpnet`.
- **Nginx:** único punto de entrada (`8080`). Para producción, sumá TLS (certificados en `nginx/`) y proxy front-end.
- `DISALLOW_FILE_EDIT` activo en WordPress (editor de plugins deshabilitado).
- Backups corren con usuario dedicado, no root.

## Estructura de datos
`data/` está en `.gitignore` (volúmenes bind mount, no se commitean):
```
data/
├── db/          # MariaDB (propietario: dnsmasq/systemd-journal por el contenedor)
├── redis/       # AOF + RDB de Redis
├── wordpress/   # /var/www/html (www-data)
├── logs/        # logs nginx/wordpress/backup
└── backups/     # salida de ./scripts/backup_now.sh
```

## Limitaciones / roadmap
- TLS no incluido en Nginx (añadir certs + config para producción).
- No hay healthcheck del backup (es `restart: no` por diseño).
- Sin staging/CI de integración con contenedores reales (solo validación de config).
- Roadmap: soporte multi-sitio, restore automatizado, métricas Prometheus.

## Licencia
MIT — ver [LICENSE](LICENSE).
