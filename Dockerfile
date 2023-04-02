FROM vaultwarden/server:1.28.1-alpine

RUN apk add --no-cache bash

COPY start.sh /start.sh
RUN chmod 755 /start.sh
