#!/bin/sh

BASE_DIR=$(cd "$(dirname "$0")" && pwd)
DATA_DIR="${BASE_DIR}/data"
CONFIG_FILE="${DATA_DIR}/config"
CONTAINER_NAME='ipfs-key-node'

cleanup() {
	docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1
	sudo rm -rf "${DATA_DIR}"
}

trap cleanup EXIT

sudo rm -rf "${DATA_DIR}" >/dev/null 2>&1
docker run -d \
	--name "${CONTAINER_NAME}" \
	-v "${DATA_DIR}:/data/ipfs" \
	ipfs/kubo:v0.34.1 daemon --init \
	>/dev/null 2>&1

while [ ! -f "${CONFIG_FILE}" ]; do
	sleep 1
done

PEER_ID=$(grep '"PeerID"' "${CONFIG_FILE}" | sed -E 's/.*"PeerID": *"([^"]+)".*/\1/')
PRIV_KEY=$(grep '"PrivKey"' "${CONFIG_FILE}" | sed -E 's/.*"PrivKey": *"([^"]+)".*/\1/')
printf 'PeerId %s\nPrivKey %s\n' "${PEER_ID}" "${PRIV_KEY}"
