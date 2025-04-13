#!/bin/sh

# Uploads target directory to IPFS

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/.env"
. "${SCRIPTS_DIR}/constants.sh"

TMP_FORM="/tmp/ipfs_upload_form.$$"
trap 'rm -f "$TMP_FORM"' EXIT

# Build the curl -F args dynamically
touch "$TMP_FORM"

TARGET_DIR="${TARGET_DIR%/}"
find "$TARGET_DIR" -type f | sort | while IFS= read -r file; do
	RELPATH="${file#$TARGET_DIR/}"
	printf '%s\n' "-F \"file=@${file};filename=${RELPATH}\"" >>"$TMP_FORM"
done
CMD="curl -s -X POST '${KUBO_API_ADDRESS}/add?recursive=true&wrap-with-directory=true&cid-version=1'"
while IFS= read -r line; do
	CMD="$CMD $line"
done <"$TMP_FORM"

# Check until Kubo container is up
while :; do
	STATUS=$(curl -o /dev/null -w "%{http_code}" -s -X POST "${KUBO_API_ADDRESS}/id" || echo 0)
	if [ "${STATUS}" = 200 ]; then
		break
	fi
	sleep 1
done

# API call to add the target directory
RESPONSE=$(eval "${CMD}")
CID=$(echo "${RESPONSE}" | jq -r 'select(.Name == "") | .Hash')

if [ -z "${CID}" ] || [ "${CID}" = "null" ]; then
	echo "Upload failed, no CID returned" >&2
	printf 'Response: %s\n' "${RESPONSE}" >&2
	exit 1
fi

echo "${CID}"
