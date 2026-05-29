# wordpress-deploy

Production-grade WordPress deployment using Docker Compose with MariaDB, Redis object cache, Nginx reverse proxy, and automated backups.

## Stack

Docker Compose, WordPress (php8.2-apache), MariaDB 10.11, Redis 7, Nginx 1.27

## Services

| Service | Description |
|---|---|
| MariaDB | Database server |
| WordPress | PHP application server |
| Nginx | Reverse proxy |
| Redis | Object cache |
| backup | Automated DB/file backup |

## Usage

```bash
cp .env.example .env
# Edit .env with your configuration
docker compose up -d
```

## Structure

```
wordpress-deploy/
├── docker-compose.yml
├── nginx/       # Nginx config
├── php/         # Custom PHP config
├── redis/       # Redis config
├── backup/      # Backup scripts
├── data/        # Persistent volumes
└── scripts/     # Utility scripts
```

## License

MIT
