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
	until git clone --quiet "${REPO_ADDRESS}" --branch "${REPO_BRANCH}" --single-branch .; do
		printf "Couldn't clone repository: %s\n" "${REPO_ADDRESS}" >&2
		echo 'Trying again in 10 seconds...' >&2
		sleep 10
	done
	printf "true"
	exit 0
fi

until git fetch origin --quiet; do
	printf "Couldn't fetch from repository: %s\n" "${REPO_ADDRESS}" >&2
	echo "Trying again in 10 seconds..." >&2
	sleep 10
done

if ! git diff --quiet "${REPO_BRANCH}" "origin/${REPO_BRANCH}"; then
	until git pull --quiet; do
		printf "Couldn't pull from repository: %s\n" "${REPO_ADDRESS}" >&2
		echo "Trying again in 10 seconds..." >&2
		sleep 10
	done
fi

printf "false"
