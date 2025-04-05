# Stage 1: Builder
FROM golang:1.24 AS builder

WORKDIR /build
RUN apt-get update && apt-get install -y wget
RUN wget https://dist.ipfs.tech/kubo/v0.34.1/kubo_v0.34.1_linux-amd64.tar.gz && \
    tar -xvzf kubo_v0.34.1_linux-amd64.tar.gz

# Stage 2: Final
FROM debian:bookworm-slim

# Copy over the Kubo binary
COPY --from=builder /build/kubo/ipfs /usr/local/bin/ipfs

# Swarm TCP; should be exposed to the public
EXPOSE 4001
# Swarm UDP; should be exposed to the public
EXPOSE 4001/udp
# Daemon API; must not be exposed publicly but to client services under you control
EXPOSE 5001
# Web Gateway; can be exposed publicly with a proxy, e.g. as https://ipfs.example.org
EXPOSE 8080
# Swarm Websockets; must be exposed publicly when the node is listening using the websocket transport (/ipX/.../tcp/8081/ws).
EXPOSE 8081

# Environment variables
ENV IPFS_PATH=/data/ipfs
ENV GOLOG_LOG_LEVEL=""

# Create the fs-repo directory and user
RUN groupadd -g 1000 ipfs && \
    useradd -u 1000 -g ipfs -m -d /data/ipfs ipfs && \
    mkdir -p /data/ipfs /ipfs /ipns /container-init.d && \
    chown -R ipfs:ipfs /data/ipfs /ipfs /ipns /container-init.d

# Copy the custom config
COPY data/kubo_config/config /config
RUN chown ipfs:ipfs /config && chmod 644 /config

# Copy the custom start script
COPY configuration/kubo_config/start_ipfs /usr/local/bin/start_ipfs
RUN chmod +x /usr/local/bin/start_ipfs

# Set volume
VOLUME $IPFS_PATH

# Run as non-root user
USER ipfs

ENTRYPOINT ["/usr/local/bin/start_ipfs"]

# Default command
CMD ["ipfs", "daemon", "--enable-namesys-pubsub"]
