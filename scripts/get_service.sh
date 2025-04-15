#!/bin/sh

set -e

. './.env'

cwd=$(pwd)

# Download service.json if not present
if [ -n "${SERVICE_GIT_BRANCH}" ]; then
	echo "Downloading service.json..."
	TMP_DIR=$(mktemp -d)

	trap 'rm -rf ${TMP_DIR}' EXIT

	cd "${TMP_DIR}"
	git clone "${SERVICE_GIT_ADDRESS}" .
	git checkout --quiet "${SERVICE_GIT_BRANCH}"
	mv "./service.json" "${cwd}/data/ipfs_cluster_data/"
else
	echo "Copying existing service.json to shared volume..."
	cp "${cwd}/configuration/service.json" "${cwd}/data/ipfs_cluster_data/"
fi

echo "service.json ready"
