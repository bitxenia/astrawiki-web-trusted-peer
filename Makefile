# Variables
COMPOSE_FILE = docker-compose.yml

# Start the services with Docker Compose
up:
	python3 scripts/generate_kubo_config.py
	python3 scripts/generate_ipfs_cluster_config.py
	docker compose -f $(COMPOSE_FILE) up -d
.PHONY: up

# Stop the services
down:
	docker compose -f $(COMPOSE_FILE) down
.PHONY: down

# View logs from the services
logs:
	docker compose -f $(COMPOSE_FILE) logs -f
.PHONY: logs

# Generate IPFS PeerID and private key for .env
generate_ipfs_keys:
	scripts/generate_ipfs_keys > keys
.PHONY: generate_ipfs_keys
