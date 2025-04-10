#!/bin/sh

# Wait for all peers to pin the new content

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

MAX_TRIES=10
tries=0
while :; do
	PEERS_NOT_DONE=$(
		curl -s "${CLUSTER_API_ADDRESS}/pins/$1" |
			jq -r '.peer_map | to_entries[] | select(.value.status != "pinned") | .key' |
			wc
	)

	[ "${PEERS_NOT_DONE}" ] && break

	tries=$(("${tries}" + 1))
	[ "${tries}" -ne "${MAX_TRIES}" ] && exit 1

	printf 'Waiting on these peers:\n%s\n' "${PEERS_NOT_DONE}"
	sleep 5
done
