#!/bin/sh

# Updates IPNS name with the new CID and a key

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

IPNS_KEYS_DIR="/usr/share/ipns_data/ipns_keys"

# Check if key import is needed
RESPONSE=$(curl -s -X POST "${KUBO_API_ADDRESS}/key/list")
IMPORT_NEEDED=$(echo "$RESPONSE" | jq --arg name "$2" '(.Keys | length == 0) or (all(.Keys[]; .Name != $name))')

if [ "${IMPORT_NEEDED}" = true ]; then
	RESPONSE=$(curl -s -X POST -F "file=@${IPNS_KEYS_DIR}/$2.key" "${KUBO_API_ADDRESS}/key/import?arg=$2")
	NAME=$(echo "${RESPONSE}" | jq -r '.Name')
	if [ "${NAME}" != "$2" ]; then
		echo "Failed to import IPNS key with response ${RESPONSE}"
		exit 1
	fi
	printf 'IPNS key "%s.key" imported\n' "${NAME}"
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
