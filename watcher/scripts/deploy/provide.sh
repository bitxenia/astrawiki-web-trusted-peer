#!/bin/sh

# Receives a CID and manually provides it. Also receives a boolean to decide
# whether to recursively provide or not.

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

cid="$1"
recursive="$2"

start=$(date +%s)
if [ "${recursive}" = 'true' ]; then
	response=$(curl -sS -w '\n%{http_code}' -X POST "${KUBO_API_ADDRESS}/routing/provide?arg=${cid}&recursive=true")
else
	response=$(curl -sS -w '\n%{http_code}' -X POST "${KUBO_API_ADDRESS}/routing/provide?arg=${cid}")
fi
body=$(echo "${response}" | sed '$d')
status=$(echo "${response}" | tail -n1)

if [ "${status}" != 200 ]; then
	echo "Failed to provide ${cid} with status ${status}" >&2
	echo "Response: ${body}" >&2
	exit 1
fi
end=$(date +%s)
duration=$((end - start))
printf 'CID %s provided in %s seconds\n' "${cid}" "${duration}"
