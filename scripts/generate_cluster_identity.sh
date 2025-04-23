#!/bin/sh

set -e

CONFIG_DIR='./configuration/ipfs_cluster_config'
SAVED_IDENTITY_PATH="${CONFIG_DIR}/identity.json"
TARGET_IDENTITY_PATH='./data/ipfs_cluster_data/identity.json'

if [ ! -f "${SAVED_IDENTITY_PATH}" ]; then
	echo 'Identity not found, generating...'
	RESPONSE=$('./scripts/generate_identity.sh')

	PEER_ID=$(echo "${RESPONSE}" | grep 'PeerId' | cut -d' ' -f2)
	PRIVATE_KEY=$(echo "${RESPONSE}" | grep 'PrivKey' | cut -d' ' -f2)
	if [ -z "${PEER_ID}" ] || [ -z "${PRIVATE_KEY}" ]; then
		echo 'Failed to generate identity'
		exit 1
	fi
	mkdir -p "${CONFIG_DIR}"
	printf '{"id": "%s", "private_key": "%s"}\n' "${PEER_ID}" "${PRIVATE_KEY}" >"${SAVED_IDENTITY_PATH}"
fi

cp "${SAVED_IDENTITY_PATH}" "${TARGET_IDENTITY_PATH}"
echo "identity.json ready."
