#!/bin/sh

# Enable IP forwarding (both IPv4 and IPv6)
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1

_term() {
    echo "Caught SIGTERM signal. Logging out and cleaning up."
    trap - TERM
    kill -TERM $TAILSCALE_DAEMON_PID
    wait $TAILSCALE_DAEMON_PID
}

trap _term TERM

/app/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
TAILSCALE_DAEMON_PID=$!

# /app/tailscale up --ssh --authkey="${TAILSCALE_AUTHKEY}" --hostname="${KOYEB_APP_NAME}" --advertise-routes="10.2.208.6/32" --accept-dns=true
#/app/tailscale up --ssh --authkey=${TAILSCALE_AUTHKEY} --hostname="koyeb-${KOYEB_APP_NAME}-${KOYEB_SERVICE_NAME}" --advertise-exit-node
#/app/tailscale up --ssh --authkey=${TAILSCALE_AUTHKEY} --hostname="koyeb-${KOYEB_APP_NAME}-${KOYEB_SERVICE_NAME}" --advertise-exit-node --accept-dns=true

#https://tailscale.com/kb/1364/serverless
#/app/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055 &
#/app/tailscale up -ssh --authkey=${TAILSCALE_AUTHKEY} --hostname="koyeb-${KOYEB_APP_NAME}-${KOYEB_SERVICE_NAME}"

/app/tailscale up --ssh --authkey=${TAILSCALE_AUTHKEY} --hostname="koyeb-${KOYEB_APP_NAME}-${KOYEB_SERVICE_NAME}" --advertise-routes=10.3.0.0/16 --accept-dns=true 
#/app/tailscale up --ssh --authkey=${TAILSCALE_AUTHKEY} --hostname=${HOSTNAME}

wait
