#!/bin/sh

# Starts watcher service

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

while :; do
	BUILD_NEEDED=$("${SCRIPTS_DIR}/pull_repo.sh")
	if [ "${BUILD_NEEDED}" = true ]; then
		echo "Repository updated/cloned"
		"${SCRIPTS_DIR}/build.sh"
		echo "Source code built"
		"${SCRIPTS_DIR}/deploy.sh"
		echo "Target directory deployed to IPFS, IPNS name can be found in ./data/ipns_data/name"
	else
		echo "Build not needed, skipping..."
	fi
	sleep 60
done
