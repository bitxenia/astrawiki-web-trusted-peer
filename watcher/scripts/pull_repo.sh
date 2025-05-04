#!/bin/sh

# Checks if git cloning/pulling is necessary, performs the operation, and
# returns true if it was needed.
#
# Parameters: git repo address, git repo branch, source directory

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"
. "${SCRIPTS_DIR}/.env"

repo_address="$1"
repo_branch="$2"
src_dir="$3"

cd "${src_dir}" || exit 1

git config --global url."https://github.com/".insteadOf git@github.com:

if [ ! -d ".git" ]; then
	until git clone --quiet "${repo_address}" --branch "${repo_branch}" --single-branch .; do
		printf "Couldn't clone repository: %s\n" "${repo_address}" >&2
		echo 'Trying again in 10 seconds...' >&2
		sleep 10
	done
	printf "true"
	exit 0
fi

until git fetch origin --quiet; do
	printf "Couldn't fetch from repository: %s\n" "${repo_address}" >&2
	echo "Trying again in 10 seconds..." >&2
	sleep 10
done

if ! git diff --quiet "${repo_branch}" "origin/${repo_branch}"; then
	until git pull --quiet; do
		printf "Couldn't pull from repository: %s\n" "${repo_address}" >&2
		echo "Trying again in 10 seconds..." >&2
		sleep 10
	done
fi

printf "false"
