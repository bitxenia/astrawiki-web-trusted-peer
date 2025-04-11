#!/bin/sh

# Updates IPNS name with the new CID

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

RESPONSE=$(curl -s -X POST "${KUBO_API_ADDRESS}/name/publish?arg=/ipfs/$1&ttl=1m")

# Extract HTTP status code
STATUS=$(echo "$RESPONSE" | jq -r '.Name' >/dev/null 2>&1 && echo 200 || echo 500)

if [ "$STATUS" -ne 200 ]; then
	echo "Failed to publish CID to IPNS"
	exit 1
fi

# Print the IPNS name
IPNS_NAME=$(echo "$RESPONSE" | jq -r '.Name')
echo "/ipns/${IPNS_NAME}" >/usr/share/ipns_data/name
echo "IPNS Name updated! Name: ${IPNS_NAME}"
