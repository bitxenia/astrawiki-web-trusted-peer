# Variables
COMPOSE_FILE = docker-compose.yml

# Start the services with Docker Compose
up:
	@test -f .env || (echo ".env file is missing!" && exit 1)
	python3 scripts/generate_kubo_config.py
	python3 scripts/generate_ipfs_cluster_config.py
	./scripts/build_custom_kubo.sh
	docker compose build
	docker compose -f $(COMPOSE_FILE) up -d
.PHONY: up

# Stop the services
down:
	docker compose -f $(COMPOSE_FILE) down
.PHONY: down

# Restart the services
restart: down up
.PHONY: restart

build:
	docker compose build
.PHONY: build

rebuild: down build up
.PHONY: rebuild

# View logs from the services
logs:
	docker compose -f $(COMPOSE_FILE) logs -f
.PHONY: logs

# Generate IPFS PeerID and private key for .env
identity:
	./scripts/generate_identity.sh
.PHONY: identity

# Execute a shell in the IPFS Cluster container
shell-cluster:
	docker exec -it ipfs_cluster sh
.PHONY: shell-cluster

# Execute a shell in the IPFS container
shell-ipfs:
	docker exec -it ipfs_node sh
.PHONY: shell-ipfs