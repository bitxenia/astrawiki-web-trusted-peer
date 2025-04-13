#!/bin/sh

# Pins given CID to the IPFS Cluster

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

# Check until Cluster container is up
while :; do
	STATUS=$(curl -o /dev/null -w "%{http_code}" -s "${CLUSTER_API_ADDRESS}/health" || echo 0)
	if [ "${STATUS}" = "204" ]; then
		break
	fi
	sleep 1
done

PIN_RESPONSE=$(
	curl -s -o /dev/null -w "%{http_code}" -X POST "${CLUSTER_API_ADDRESS}/pins/$1"
)
if [ "$PIN_RESPONSE" -ne 200 ]; then
	echo "Failed to pin CID with IPFS Cluster (status code: $PIN_RESPONSE)" >&2
	exit 1
fi
