#!/bin/sh

# Starts watcher service

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"
. "${SCRIPTS_DIR}/.env"

while :; do
	DEPLOY_NEEDED=$("${SCRIPTS_DIR}/pull_repo.sh")
	if [ "${DEPLOY_NEEDED}" = true ]; then
		echo "Change detected, re-deploy needed"
		cp -r "${SRC_DIR}/${BUILD_DIR}/." "${TARGET_DIR}/"
		"${SCRIPTS_DIR}/deploy.sh"
	else
		echo "Build not needed, skipping..."
	fi
	sleep 60
done
