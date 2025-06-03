#!/bin/sh

# Wait for Kubo container to be up

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

echo "Waiting for Kubo..."

while :; do
	status=$(curl -s -o /dev/null -w '%{http_code}' -X POST "${KUBO_API_ADDRESS}/id" || echo '000')
	if [ "${status}" = 200 ]; then
		break
	fi
	printf 'Kubo not up, status code %s\n' "${status}"
	sleep 5
done

echo "Kubo container up"
