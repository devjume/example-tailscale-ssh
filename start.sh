#!/bin/sh

#echo $KOYEB_APP_NAME
#echo $KOYEB_SERVICE_NAME

#HOSTNAME="${KOYEB_APP_NAME}-${KOYEB_SERVICE_NAME}"
#echo HOSTNAME

_term() {
    echo "Caught SIGTERM signal. Logging out and cleaning up."
    trap - TERM
    kill -TERM $TAILSCALE_DAEMON_PID
    wait $TAILSCALE_DAEMON_PID
}

trap _term TERM


/app/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
TAILSCALE_DAEMON_PID=$!
/app/tailscale up --ssh --authkey=${TAILSCALE_AUTHKEY} --advertise-exit-node --accept-dns=false
#/app/tailscale up --ssh --authkey=${TAILSCALE_AUTHKEY} --hostname=${HOSTNAME} --advertise-exit-node

wait
