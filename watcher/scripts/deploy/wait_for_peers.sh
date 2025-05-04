#!/bin/sh

# Wait for all peers to pin the new content

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

while :; do
	peers_not_done=$(
		curl -s "${CLUSTER_API_ADDRESS}/pins/$1" |
			jq -r '.peer_map | to_entries[] | select(.value.status != "pinned") | .key'
	)

	amount_of_peers=$(echo "${peers_not_done}" | grep -c .)

	[ "${amount_of_peers}" -eq 0 ] && break

	printf 'Waiting on these peers:\n%s\n' "${peers_not_done}"
	sleep 5
done
