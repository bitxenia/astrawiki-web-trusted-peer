#!/bin/sh

# Starts watcher service

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"
. "${SCRIPTS_DIR}/.env"

CONTENT_SOURCE_DIR="/usr/local/share/content-src"
readonly CONTENT_SOURCE_DIR
mkdir "${CONTENT_SOURCE_DIR}"

CONTENT_TARGET_DIR="/usr/local/share/content-target"
readonly CONTENT_TARGET_DIR

SERVICE_SOURCE_DIR="/usr/local/share/service-src"
readonly SERVICE_SOURCE_DIR
mkdir "${SERVICE_SOURCE_DIR}"
SERVICE_TARGET_DIR="/usr/local/share/service-target"
readonly SERVICE_TARGET_DIR

"${SCRIPTS_DIR}/wait_for_kubo.sh"
"${SCRIPTS_DIR}/wait_for_cluster.sh"

while :; do
	content_deploy_needed=$("${SCRIPTS_DIR}/pull_repo.sh" "${CONTENT_GIT_ADDRESS}" "${CONTENT_GIT_BRANCH}" "${CONTENT_SOURCE_DIR}")
	service_deploy_needed=$("${SCRIPTS_DIR}/pull_repo.sh" "${SERVICE_GIT_ADDRESS}" "${SERVICE_GIT_BRANCH}" "${SERVICE_SOURCE_DIR}")

	if [ "${content_deploy_needed}" = true ] || [ "$service_deploy_needed" = true ]; then
		echo "Change detected, re-deploy needed"
		cp -r "${CONTENT_SOURCE_DIR}/." "${CONTENT_TARGET_DIR}/"
		rm -rf "${CONTENT_TARGET_DIR}/.git"
		cp -r "${SERVICE_SOURCE_DIR}/." "${SERVICE_TARGET_DIR}/"
		"${SCRIPTS_DIR}/deploy.sh" "${CONTENT_TARGET_DIR}" "${SERVICE_TARGET_DIR}"
		echo "Changes deployed"
	else
		echo "Build not needed, skipping..."
	fi
	sleep 60
done
