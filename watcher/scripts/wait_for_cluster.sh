#!/bin/sh

# Check until Cluster container is up

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

echo "Waiting for IPFS Cluster..."

while :; do
	status=$(curl -o /dev/null -w "%{http_code}" -s "${CLUSTER_API_ADDRESS}/health" || echo 0)
	if [ "${status}" = "204" ]; then
		break
	fi
	printf 'IPFS Cluster not up, status code %s\n' "${status}"
	sleep 5
done

echo "IPFS Cluster up"
