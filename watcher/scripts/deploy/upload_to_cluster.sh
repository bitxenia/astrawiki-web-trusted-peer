#!/bin/sh

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/.env"
. "${SCRIPTS_DIR}/constants.sh"

TMP_FORM="/tmp/ipfs_upload_form.$$"
trap 'rm -f "$TMP_FORM"' EXIT

# Build the curl -F args dynamically
>"$TMP_FORM"
TARGET_DIR="${TARGET_DIR%/}"
find "$TARGET_DIR" -type f | sort | while IFS= read -r file; do
	RELPATH="${file#$TARGET_DIR/}"
	printf '%s\n' "-F \"file=@${file};filename=${RELPATH}\"" >>"$TMP_FORM"
done
CMD="curl -s -X POST '${CLUSTER_API_ADDRESS}/add?wrap-with-directory=true&cid-version=1'"
while IFS= read -r line; do
	CMD="$CMD $line"
done <"$TMP_FORM"

# Check until Cluster container is up
while :; do
	STATUS=$(curl -o /dev/null -w "%{http_code}" -s "${CLUSTER_API_ADDRESS}/health" || echo 0)
	if [ "${STATUS}" = "204" ]; then
		break
	fi
	sleep 1
done

# API call to add the target directory
RESPONSE=$(eval "${CMD}")
CID=$(echo "${RESPONSE}" | jq -r 'select(.name == "") | .cid')

if [ -z "${CID}" ] || [ "${CID}" = "null" ]; then
	echo "Upload failed, no CID returned" >&2
	exit 1
fi

echo "${CID}"
