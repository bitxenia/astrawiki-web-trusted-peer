#!/bin/sh

# Removes all pins except the one given

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

# Unpin any old pins
curl -s "${CLUSTER_API_ADDRESS}/pins" |
	jq -r --arg exclude "$1" 'select(.cid != $exclude) | .cid' |
	while IFS= read -r cid; do
		curl -s -o /dev/null -X DELETE "${CLUSTER_API_ADDRESS}/pins/${cid}"
		echo "Unpinned ${cid}"
	done

# Wait for all peers to pin the new content
while :; do
	PEERS_NOT_DONE=$(curl -s "${CLUSTER_API_ADDRESS}/pins/$1" |
		jq -r '.peer_map | to_entries[] | select(.value.status != "pinned") | .key')

	[ -z "${PEERS_NOT_DONE}" ] && break

	printf 'Waiting on these peers:\n%s\n' "${PEERS_NOT_DONE}"
	sleep 5
done
