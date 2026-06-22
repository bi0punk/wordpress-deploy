# wordpress-deploy

Production-grade WordPress deployment using Docker Compose with MariaDB, Redis object cache (secured), Nginx reverse proxy, and automated backups.

**Security:** Redis requires authentication and binds to localhost only.

## Stack

Docker Compose, WordPress (php8.2-apache), MariaDB 10.11, Redis 7, Nginx 1.27

## Services

| Service | Description |
|---|---|
| MariaDB | Database server |
| WordPress | PHP application server |
| Nginx | Reverse proxy |
| Redis | Object cache (password protected) |
| backup | Automated DB/file backup |

## Usage

```bash
cp .env.example .env
# Edit .env with your configuration
docker compose up -d
```

## Configuration

Set these in `.env`:

| Variable | Default | Description |
|---|---|---|
| `MYSQL_ROOT_PASSWORD` | — | MariaDB root password |
| `MYSQL_DATABASE` | `wordpress` | Database name |
| `MYSQL_USER` | `wpuser` | WordPress DB user |
| `MYSQL_PASSWORD` | — | WordPress DB password |
| `REDIS_PASSWORD` | `changeme` | Redis auth password |

## Redis Security

- Redis binds to `127.0.0.1` only (no external access)
- Authentication required via `requirepass` (set `REDIS_PASSWORD` env var)
- Used exclusively as WordPress object cache via `wp-redis`

## Structure

```
wordpress-deploy/
├── docker-compose.yml
├── nginx/       # Nginx config
├── php/         # Custom PHP config
├── redis/       # Redis config (secured)
├── backup/      # Backup scripts
├── data/        # Persistent volumes
└── scripts/     # Utility scripts
```

## Security Notes

- Redis: password-protected, localhost-only binding
- Nginx recommended as TLS termination proxy (add SSL certs to `nginx/`)
- Database backup uses dedicated backup user (not root)
- All services run on internal Docker network

## License

MIT
