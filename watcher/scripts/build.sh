#!/bin/sh

# Builds the target directory content from the source files

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"
. "${SCRIPTS_DIR}/.env"

cd "${SRC_DIR}"
npm install
npm run build

cp -r "${SRC_DIR}/${BUILD_DIR}/." "${TARGET_DIR}/"
