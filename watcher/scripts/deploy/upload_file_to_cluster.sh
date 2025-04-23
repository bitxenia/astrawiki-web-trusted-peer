#!/bin/sh

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/.env"
. "${SCRIPTS_DIR}/constants.sh"

FILE_PATH="$1"
if [ ! -f "$FILE_PATH" ]; then
	echo "File not found: ${FILE_PATH}" >&2
	exit 1
fi

# Check until Cluster container is up
while :; do
	STATUS=$(curl -o /dev/null -w "%{http_code}" -s "${CLUSTER_API_ADDRESS}/health" || echo 0)
	if [ "${STATUS}" = "204" ]; then
		break
	fi
	sleep 1
done

# API call to add the target directory
RESPONSE=$(curl -s -X POST -F "file=@${FILE_PATH};filename=$(basename "${FILE_PATH}")" "${CLUSTER_API_ADDRESS}/add?cid-version=1")
CID=$(echo "${RESPONSE}" | jq -r '.cid')

if [ -z "${CID}" ] || [ "${CID}" = "null" ]; then
	echo "Upload failed, no CID returned" >&2
	exit 1
fi

echo "${CID}"
