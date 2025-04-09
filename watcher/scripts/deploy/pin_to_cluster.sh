#!/bin/sh

# Pins given CID to the IPFS Cluster

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

PIN_RESPONSE=$(
	curl -s -o /dev/null -w "%{http_code}" -X POST "${CLUSTER_API_ADDRESS}/pins/$1"
)
if [ "$PIN_RESPONSE" -ne 200 ]; then
	echo "Failed to pin CID with IPFS Cluster (status code: $PIN_RESPONSE)"
	exit 1
fi
