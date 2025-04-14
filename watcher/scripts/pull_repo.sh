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
	if ! git clone --quiet "${REPO_GIT_ADDRESS}" .; then
		echo "Failed to clone git repository" >&2
		exit 1
	fi
	printf "true"
	exit 0
fi

git fetch origin --quiet

if ! git diff --quiet "${MAIN_GIT_BRANCH}" "origin/${MAIN_GIT_BRANCH}"; then
	if ! git pull --quiet; then
		echo "Failed to pull git repository" >&2
		exit 1
	else
		printf "true"
		exit 0
	fi
fi

printf "false"
