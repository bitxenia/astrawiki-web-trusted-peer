#!/bin/sh

# Removes all pins except the ones given

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

curl -s "${CLUSTER_API_ADDRESS}/pins" |
	jq -r --arg exclude1 "$1" --arg exclude2 "$2" 'select(.cid != $exclude1 and .cid != $exclude2) | .cid' |
	while IFS= read -r cid; do
		curl -s -o /dev/null -X DELETE "${CLUSTER_API_ADDRESS}/pins/${cid}"
		echo "Unpinned ${cid}"
	done
