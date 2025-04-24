# Variables
COMPOSE_FILE = docker-compose.yml

# Initialize configuration
init:
	./scripts/init_config.sh
.PHONY: init

# Start the services with Docker Compose
up:
	@test -f .env || (echo ".env file is missing!" && exit 1)
	./scripts/get_service.sh
	./scripts/generate_cluster_identity.sh
	./scripts/copy_ipns_keys.sh
	docker compose -f $(COMPOSE_FILE) up -d --build
.PHONY: up

# Stop the services
down:
	docker compose -f $(COMPOSE_FILE) down
.PHONY: down

# Restart the services
restart: down up
.PHONY: restart

# View logs from the services
logs:
	docker compose -f $(COMPOSE_FILE) logs -f
.PHONY: logs

# Generate IPFS PeerID and private key for .env
identity:
	./scripts/generate_identity.sh
.PHONY: identity

# Generate IPNS keys
ipns_keys:
	./scripts/generate_ipns_keys.sh
.PHONY: ipns_keys

# Execute a shell in the IPFS Cluster container
shell-cluster:
	docker exec -it ipfs_cluster sh
.PHONY: shell-cluster

# Execute a shell in the IPFS container
shell-ipfs:
	docker exec -it ipfs_node sh
.PHONY: shell-ipfs
