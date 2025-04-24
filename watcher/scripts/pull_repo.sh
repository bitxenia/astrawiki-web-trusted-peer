#!/bin/sh

# Checks if git cloning/pulling is necessary, performs the operation, and
# returns true if it was needed.
#
# Parameters: git repo address, git repo branch, source directory

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"
. "${SCRIPTS_DIR}/.env"

REPO_ADDRESS="$1"
REPO_BRANCH="$2"
SRC_DIR="$3"

cd "${SRC_DIR}" || exit 1

git config --global url."https://github.com/".insteadOf git@github.com:

if [ ! -d ".git" ]; then
	if ! git clone --quiet "${REPO_ADDRESS}" .; then
		echo "Failed to clone git repository" >&2
		exit 1
	fi
	printf "true"
	exit 0
fi

if ! git fetch origin --quiet; then
	echo "Failed to fetch from repository: ${REPO_ADDRESS}" >&2
	exit 1
fi
if ! git checkout --quiet "${REPO_BRANCH}"; then
	echo "Failed to checkout to branch ${REPO_BRANCH} in ${REPO_ADDRESS}" >&2
	exit 1
fi

if ! git diff --quiet "${REPO_BRANCH}" "origin/${REPO_BRANCH}"; then
	if ! git pull --quiet; then
		echo "Failed to pull git repository" >&2
		exit 1
	else
		printf "true"
		exit 0
	fi
fi

printf "false"
