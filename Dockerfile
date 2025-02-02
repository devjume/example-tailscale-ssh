FROM ubuntu:latest
WORKDIR /app 

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    iptables bash curl sudo iputils-ping dnsutils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Enable IP forwarding for IPv4 and IPv6
# https://tailscale.com/kb/1103/exit-nodes?tab=linux
#RUN echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/99-tailscale.conf && \
#    echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.d/99-tailscale.conf && \
#    sysctl -p /etc/sysctl.d/99-tailscale.conf

RUN echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf && \
    echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf && \
    sudo sysctl -p /etc/sysctl.conf

# Copy Tailscale binaries
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscaled /app/tailscaled
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscale /app/tailscale

# Create necessary directories for Tailscale
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

# Create a non-root user and grant sudo privileges
RUN useradd -m -s /bin/bash tailscale-user && \
    echo "tailscale-user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Ensure the non-root user has permission to access the Tailscale directories
RUN chown -R tailscale-user:tailscale-user /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

# Copy the startup script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Switch to the non-root user
USER tailscale-user

CMD ["sudo", "/app/start.sh"]
