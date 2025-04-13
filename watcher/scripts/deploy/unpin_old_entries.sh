#!/bin/sh

# Removes all pins except the one given

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

curl -s "${CLUSTER_API_ADDRESS}/pins" |
	jq -r --arg exclude "$1" 'select(.cid != $exclude) | .cid' |
	while IFS= read -r cid; do
		curl -s -o /dev/null -X DELETE "${CLUSTER_API_ADDRESS}/pins/${cid}"
		echo "Unpinned ${cid}"
	done
