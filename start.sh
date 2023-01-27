#!/usr/bin/env bash

set -e

echo "Writing keys"
echo "$RSA_KEY" > /tmp/rsa_key.pem
echo "$RSA_KEY_PUB" > /tmp/rsa_key.pub.pem

RUN_TIMEOUT=${RUN_TIMEOUT:-300}

timeout_pid=
timeout() {
    if [ -n "$timeout_pid" ]; then
        kill -s SIGTERM "$timeout_pid"
    fi
    (sleep "$RUN_TIMEOUT" && echo "No output for $RUN_TIMEOUT seconds" && kill -s SIGTERM "$(cat /tmp/vaultwarden.pid)") &
    timeout_pid=$!
}

while read -r line; do
    echo "$line"
    timeout
done < <(/vaultwarden "$@" & echo "$!" >/tmp/vaultwarden.pid; wait "$!" || true)

echo "Exiting"
exit 0
