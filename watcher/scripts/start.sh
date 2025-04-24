#!/bin/sh

# Starts watcher service

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"
. "${SCRIPTS_DIR}/.env"

CONTENT_SOURCE_DIR="/usr/local/share/content-src"
mkdir "${CONTENT_SOURCE_DIR}"
CONTENT_TARGET_DIR="/usr/local/share/content-target"
SERVICE_SOURCE_DIR="/usr/local/share/service-src"
mkdir "${SERVICE_SOURCE_DIR}"
SERVICE_TARGET_DIR="/usr/local/share/service-target"
while :; do
	CONTENT_DEPLOY_NEEDED=$("${SCRIPTS_DIR}/pull_repo.sh" "${CONTENT_GIT_ADDRESS}" "${CONTENT_GIT_BRANCH}" "${CONTENT_SOURCE_DIR}")
	SERVICE_DEPLOY_NEEDED=$("${SCRIPTS_DIR}/pull_repo.sh" "${SERVICE_GIT_ADDRESS}" "${SERVICE_GIT_BRANCH}" "${SERVICE_SOURCE_DIR}")

	if [ "${CONTENT_DEPLOY_NEEDED}" = true ] || [ "$SERVICE_DEPLOY_NEEDED" = true ]; then
		echo "Change detected, re-deploy needed"
		cp -r "${CONTENT_SOURCE_DIR}/." "${CONTENT_TARGET_DIR}/"
		rm -rf "${CONTENT_TARGET_DIR}/.git"
		ls -l -a "${CONTENT_TARGET_DIR}"
		cp -r "${SERVICE_SOURCE_DIR}/." "${SERVICE_TARGET_DIR}/"
		"${SCRIPTS_DIR}/deploy.sh" "${CONTENT_TARGET_DIR}" "${SERVICE_TARGET_DIR}"
	else
		echo "Build not needed, skipping..."
	fi
	sleep 60
done
