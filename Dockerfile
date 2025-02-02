FROM ubuntu:latest

RUN apt-get update && \
    apt-get install --no-install-recommends -y iptables bash curl sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app 

COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscaled /app/tailscaled
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscale /app/tailscale
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
