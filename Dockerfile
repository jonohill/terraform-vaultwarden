FROM vaultwarden/server:1.27.0-alpine

COPY start.sh /start.sh
RUN chmod 755 /start.sh
