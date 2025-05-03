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
	tries=0
	MAX_TRIES=10
	readonly MAX_TRIES
	while :; do
		if ! git clone --quiet "${REPO_ADDRESS}" --branch "${REPO_BRANCH}" --single-branch .; then
			tries=$((tries + 1))
			if [ "${tries}" -eq "${MAX_TRIES}" ]; then
				echo "Failed to clone git repository" >&2
				exit 1
			fi
			printf "Couldn't clone repository: %s\n" "${REPO_ADDRESS}" >&2
			echo 'Trying again in 10 seconds...' >&2
			sleep 10
		else
			printf "true"
			exit 0
		fi
	done
fi

tries=0
MAX_TRIES=10
readonly MAX_TRIES
while :; do
	if ! git fetch origin --quiet; then
		tries=$((tries + 1))
		if [ "${tries}" -eq "${MAX_TRIES}" ]; then
			echo "Failed to fetch from repository: ${REPO_ADDRESS}" >&2
			exit 1
		fi
		printf "Couldn't fetch from repository: %s\n" "${REPO_ADDRESS}" >&2
		echo "Trying again in 10 seconds..." >&2
		sleep 10
	else
		break
	fi
done

if ! git diff --quiet "${REPO_BRANCH}" "origin/${REPO_BRANCH}"; then
	tries=0
	MAX_TRIES=10
	readonly MAX_TRIES
	while :; do
		if ! git pull --quiet; then
			tries=$((tries + 1))
			if [ "${tries}" -eq "${MAX_TRIES}" ]; then
				echo "Failed to pull git repository" >&2
				exit 1
			fi
			printf "Couldn't pull from repository: %s\n" "${REPO_ADDRESS}" >&2
			echo "Trying again in 10 seconds..." >&2
			sleep 10
		else
			printf "true"
			exit 0
		fi
	done
fi

printf "false"
