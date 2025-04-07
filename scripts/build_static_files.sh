#!/bin/sh

WEBSITE_SRC_DIR="website"

[ -f "./.env" ] && . "./.env"

mkdir -p "${WEBSITE_SRC_DIR}"

cd "${WEBSITE_SRC_DIR}" || exit 1

# Clone repo if not cloned already
if [ ! -d ".git" ]; then
	echo "Website repository not present, cloning..."
	if ! git clone --quiet "${REPO_GIT_ADDRESS}" .; then
		echo "Failed to clone repository"
		exit 1
	fi
	echo "Clone complete"
fi

git fetch origin --quiet

REBUILD_NEEDED=false

# Stash any local changes
git stash --quiet

# Check if there's new upstream changes to pull
if ! git diff --quiet "${MAIN_GIT_BRANCH}" "origin/${MAIN_GIT_BRANCH}"; then
	echo "New changes detected on the main branch, pulling..."
	if ! git pull --quiet; then
		printf 'git pull failed, check for merge conflicts and run this command manually on the %s directory\n' "${WEBSITE_SRC_DIR}"
		exit 1
	fi
	echo "New changes pulled"
	REBUILD_NEEDED=true
fi

[ ! -d "${STATIC_DIR}" ] && REBUILD_NEEDED=true

if [ "${REBUILD_NEEDED}" = "true" ]; then
	if ! git checkout --quiet "${MAIN_GIT_BRANCH}"; then
		echo "Failed to checkout to main branch, make sure it's well defined"
		exit 1
	fi
	echo "Building static files..."
	if ! eval "${BUILD_COMMAND}"; then
		echo "Build failed"
		exit 1
	else
		echo "Static files built"
	fi
fi
