#!/bin/sh

#

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/.env"
. "${SCRIPTS_DIR}/constants.sh"

TMP_FORM="/tmp/ipfs_upload_form.$$"
trap 'rm -f "$TMP_FORM"' EXIT

# Build the curl -F args dynamically
touch "$TMP_FORM"

TARGET_DIR="${TARGET_DIR%/}"
find "$TARGET_DIR" -type f | while IFS= read -r file; do
	RELPATH="${file#$TARGET_DIR/}"
	printf '%s\n' "-F \"file=@${file};filename=${RELPATH}\"" >>"$TMP_FORM"
done

# Combine curl command and eval
CMD="curl -s -X POST '${KUBO_API_ADDRESS}/add?recursive=true&wrap-with-directory=true'"

# Append each form line from the temp file
while IFS= read -r line; do
	CMD="$CMD $line"
done <"$TMP_FORM"

# Eval the full curl command and output CID
eval "${CMD}" | tail -n 1 | jq -r '.Hash'
