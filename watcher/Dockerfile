FROM alpine:latest

# TODO: Add a way to add a SSH key for private repositories
RUN apk add --no-cache curl jq git

COPY ./watcher/scripts/ /usr/local/bin/scripts/
COPY .env /usr/local/bin/scripts/

# Make sure it's executable
RUN chmod +x /usr/local/bin/scripts/*

# Set the default command
ENTRYPOINT ["/usr/local/bin/scripts/start.sh"]
