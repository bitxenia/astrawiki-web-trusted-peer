#!/bin/sh

WEBSITE_SRC_DIR="website"

if [ -f "./.env" ]; then
	. "./.env"
fi

if [ ! -d "${WEBSITE_SRC_DIR}" ]; then
	mkdir -p "${WEBSITE_SRC_DIR}"
fi

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

git fetch origin
if ! git checkout --quiet "${MAIN_GIT_BRANCH}"; then
	echo "Failed to checkout to main branch, make sure it's well defined"
	exit 1
fi

REBUILD_NEEDED=false

# Check for any staged or unstaged changes in the local directory, and stash them
if ! git diff --quiet || ! git diff --cached --quiet; then
	git stash
	REBUILD_NEEDED=true
	echo "Changes present in the website directory were stashed"
fi

# Check if there's new upstream changes to pull
if [ "$(git rev-parse "${MAIN_GIT_BRANCH}")" != "$(git rev-parse origin/"${MAIN_GIT_BRANCH}")" ]; then
	echo "New changes detected on the main branch, pulling..."
	if ! git pull; then
		printf 'git pull failed, check for merge conflicts and run this command manually on the %s directory\n' "${WEBSITE_SRC_DIR}"
		exit 1
	fi
	echo "New changes pulled"
	REBUILD_NEEDED=true
fi

if [ ! -d "${STATIC_DIR}" ]; then
	REBUILD_NEEDED=true
fi

if [ "${REBUILD_NEEDED}" = "true" ]; then
	echo "Building static files..."
	if ! eval "${BUILD_COMMAND}"; then
		echo "Build failed"
		exit 1
	else
		echo "Static files built"
	fi
else
	echo "Static files already built"
fi
