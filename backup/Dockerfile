FROM alpine:3.20
RUN apk add --no-cache bash mariadb-client tar gzip coreutils tzdata
COPY scripts/backup.sh /backup.sh
RUN chmod +x /backup.sh
