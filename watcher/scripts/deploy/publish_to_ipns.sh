#!/bin/sh

# Updates IPNS name with the new CID and a key

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

# Check if key generation is needed
RESPONSE=$(curl -s -X POST "${KUBO_API_ADDRESS}/key/list")
GEN_NEEDED=$(echo "$RESPONSE" | jq --arg name "$2" '(.Keys | length == 0) or (all(.Keys[]; .Name != $name))')

if [ "${GEN_NEEDED}" = true ]; then
	STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "${KUBO_API_ADDRESS}/key/gen?arg=$2")
	if [ "${STATUS}" -ne 200 ]; then
		echo "Failed to generate IPNS key with status ${STATUS}"
		exit 1
	fi
fi

RESPONSE=$(curl -s -X POST "${KUBO_API_ADDRESS}/name/publish?arg=/ipfs/$1&ttl=1m&key=$2")

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

echo "${IPNS_NAME}" >"/usr/share/ipns_data/name_$2"
printf 'Published to IPNS %s\n' "${IPNS_NAME}"
