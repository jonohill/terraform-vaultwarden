FROM vaultwarden/server:1.32.3-alpine

RUN apk add --no-cache bash

COPY start.sh /start.sh
RUN chmod 755 /start.sh
