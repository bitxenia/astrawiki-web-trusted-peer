#!/bin/sh

set -e

CLUSTER_DATA_PATH='./data/ipfs_cluster_data'
IDENTITY_FILE="${CLUSTER_DATA_PATH}/identity.json"

. ./.env

if [ -z "${PEER_ID}" ] || [ -z "${PRIV_KEY}" ]; then
	echo 'Identity variables not found in .env'
	exit 1
fi

mkdir -p "${CLUSTER_DATA_PATH}"
printf '{"id": "%s", "private_key": "%s"}' "${PEER_ID}" "${PRIV_KEY}" >"${IDENTITY_FILE}"

echo "identity.json ready."
