#!/bin/sh

# Wait for all peers to pin the new content

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

MAX_TRIES=20
tries=0
while :; do
	PEERS_NOT_DONE=$(
		curl -s "${CLUSTER_API_ADDRESS}/pins/$1" |
			jq -r '.peer_map | to_entries[] | select(.value.status != "pinned") | .key'
	)

	AMOUNT_OF_PEERS=$(echo "${PEERS_NOT_DONE}" | grep -c .)

	[ "${AMOUNT_OF_PEERS}" -eq 0 ] && break

	tries=$((tries + 1))
	if [ "${tries}" -eq "${MAX_TRIES}" ]; then
		echo "Timed out while waiting for peers to pin new content" >&2
		exit 1
	fi

	printf 'Waiting on these peers:\n%s\n' "${PEERS_NOT_DONE}"
	sleep 5
done
