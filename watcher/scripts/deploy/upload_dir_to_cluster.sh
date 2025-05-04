#!/bin/sh

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/.env"
. "${SCRIPTS_DIR}/constants.sh"

tmp_form="/tmp/ipfs_upload_form.$$"
trap 'rm -f "$TMP_FORM"' EXIT

# Build the curl -F args dynamically
>"$tmp_form"
target_dir="${1%/}"
find "$target_dir" -type f | sort | while IFS= read -r file; do
	relpath="${file#$target_dir/}"
	printf '%s\n' "-F \"file=@${file};filename=${relpath}\"" >>"$tmp_form"
done
cmd="curl -s -X POST '${CLUSTER_API_ADDRESS}/add?wrap-with-directory=true&cid-version=1'"
while IFS= read -r line; do
	cmd="${cmd} ${line}"
done <"$tmp_form"

# API call to add the target directory
response=$(eval "${cmd}")
cid=$(echo "${response}" | jq -r 'select(.name == "") | .cid')

if [ -z "${cid}" ] || [ "${cid}" = "null" ]; then
	echo "Upload failed, no CID returned" >&2
	exit 1
fi

echo "${cid}"
