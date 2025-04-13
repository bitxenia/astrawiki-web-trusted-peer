#!/bin/sh

# Updates IPNS name with the new CID

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

RESPONSE=$(curl -s -X POST "${KUBO_API_ADDRESS}/name/publish?arg=/ipfs/$1&ttl=1m")

IPNS_NAME=$(echo "$RESPONSE" | jq -r '.Name')
PUBLISHED_CID=$(echo "$RESPONSE" | jq -r '.Value')
if [ -z "${IPNS_NAME}" ] || [ "${IPNS_NAME}" = "null" ]; then
	echo "Failed to publish CID to IPNS" >&2
	echo "Raw response: $RESPONSE" >&2
	exit 1
fi

if [ "${PUBLISHED_CID}" != "/ipfs/$1" ]; then
	echo "IPNS resolution mismatch." >&2
	echo "Expected CID: $CID" >&2
	echo "Resolved CID: $PUBLISHED_CID" >&2
fi

IPNS_NAME="/ipns/${IPNS_NAME}"

echo "${IPNS_NAME}" >/usr/share/ipns_data/name
echo "${IPNS_NAME}"
