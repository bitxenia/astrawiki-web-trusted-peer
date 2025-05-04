#!/bin/sh

# Check until Cluster container is up

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

while :; do
	STATUS=$(curl -o /dev/null -w "%{http_code}" -s "${CLUSTER_API_ADDRESS}/health" || echo 0)
	if [ "${STATUS}" = "204" ]; then
		break
	fi
	sleep 5
done
