#!/bin/sh

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/.env"
. "${SCRIPTS_DIR}/constants.sh"

file_path="$1"
if [ ! -f "$file_path" ]; then
	echo "File not found: ${file_path}" >&2
	exit 1
fi

# API call to add the target directory
response=$(curl -s -X POST -F "file=@${file_path};filename=$(basename "${file_path}")" "${CLUSTER_API_ADDRESS}/add?cid-version=1")
cid=$(echo "${response}" | jq -r '.cid')

if [ -z "${cid}" ] || [ "${cid}" = "null" ]; then
	echo "Upload failed, no CID returned" >&2
	exit 1
fi

echo "${cid}"
