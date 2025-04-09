#!/bin/sh

# Checks if git cloning/pulling is necessary, performs the operation, and
# returns true if it was needed.

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"
. "${SCRIPTS_DIR}/.env"

mkdir -p "${SRC_DIR}"

cd "${SRC_DIR}" || exit 1

git config --global url."https://github.com/".insteadOf git@github.com:

if [ ! -d ".git" ]; then
	git clone --quiet "${REPO_GIT_ADDRESS}" .
	printf "true"
	exit 0
fi

git fetch origin --quiet

if ! git diff --quiet "${MAIN_GIT_BRANCH}" "origin/${MAIN_GIT_BRANCH}"; then
	if ! git pull --quiet; then
		exit 1
	else
		printf "true"
		exit 0
	fi
fi

printf "false"
