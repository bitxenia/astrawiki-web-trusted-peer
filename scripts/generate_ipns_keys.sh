#!/bin/sh

# Generates two private IPNS keys to /configuration/ipns_keys

set -e

BASE_DIR=$(cd "$(dirname "$0")" && pwd)
KEYS_DIR="$(pwd)/configuration/ipns_keys"
DATA_DIR="${BASE_DIR}/data"
KEY1_NAME="content"
KEY2_NAME="service"

sudo rm -rf "${DATA_DIR}" >/dev/null 2>&1
mkdir -p "${KEYS_DIR}"

docker run --rm \
	--entrypoint sh \
	-v "${DATA_DIR}:/data/ipfs" \
	-w '/data/ipfs' \
	ipfs/kubo:v0.34.1 \
	-c "
    ipfs init &&
    ipfs key gen ${KEY1_NAME} &&
    ipfs key gen ${KEY2_NAME} &&
    ipfs key export ${KEY1_NAME} > /data/ipfs/${KEY1_NAME}.key &&
    ipfs key export ${KEY2_NAME} > /data/ipfs/${KEY2_NAME}.key
  "

sudo cp "${DATA_DIR}/${KEY1_NAME}.key" "${KEYS_DIR}/${KEY1_NAME}.key"
sudo cp "${DATA_DIR}/${KEY2_NAME}.key" "${KEYS_DIR}/${KEY2_NAME}.key"
sudo rm -rf "${DATA_DIR}"
