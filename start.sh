#!/bin/sh

# Enable IP forwarding (both IPv4 and IPv6)
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1

echo "dog food"
echo $TAILSCALE_AUTHKEY

_term() {
    echo "Caught SIGTERM signal. Logging out and cleaning up."
    trap - TERM
    kill -TERM $TAILSCALE_DAEMON_PID
    wait $TAILSCALE_DAEMON_PID
}

trap _term TERM

/app/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
TAILSCALE_DAEMON_PID=$!

sleep 3

/app/tailscale up --ssh --authkey="${TAILSCALE_AUTHKEY}" --hostname="${KOYEB_APP_NAME}" --advertise-routes="10.2.208.6/32"
#/app/tailscale up --ssh --authkey=${TAILSCALE_AUTHKEY} --hostname=${KOYEB_APP_NAME} --advertise-exit-node
#/app/tailscale up --ssh --authkey=${TAILSCALE_AUTHKEY} --hostname=${HOSTNAME}

wait
