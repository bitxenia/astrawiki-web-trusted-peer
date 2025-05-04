#!/bin/sh

# Updates IPNS name with the new CID and a key

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

IPNS_KEYS_DIR="/usr/share/ipns_data/ipns_keys"

# Check if key import is needed
response=$(curl -s -X POST "${KUBO_API_ADDRESS}/key/list")
import_needed=$(echo "$response" | jq --arg name "$2" '(.Keys | length == 0) or (all(.Keys[]; .Name != $name))')

if [ "${import_needed}" = true ]; then
	response=$(curl -s -X POST -F "file=@${IPNS_KEYS_DIR}/$2.key" "${KUBO_API_ADDRESS}/key/import?arg=$2")
	name=$(echo "${response}" | jq -r '.Name')
	if [ "${name}" != "$2" ]; then
		echo "Failed to import IPNS key with response ${response}"
		exit 1
	fi
	printf 'IPNS key "%s.key" imported\n' "${name}"
fi

response=$(curl -s -X POST "${KUBO_API_ADDRESS}/name/publish?arg=/ipfs/$1&ttl=1m&key=$2")

ipns_name=$(echo "$response" | jq -r '.Name')
published_cid=$(echo "$response" | jq -r '.Value')
if [ -z "${ipns_name}" ] || [ "${ipns_name}" = "null" ]; then
	echo "Failed to publish CID to IPNS" >&2
	echo "Raw response: $response" >&2
	exit 1
fi

if [ "${published_cid}" != "/ipfs/$1" ]; then
	echo "IPNS resolution mismatch." >&2
	echo "Expected CID: $CID" >&2
	echo "Resolved CID: $published_cid" >&2
fi

ipns_name="/ipns/${ipns_name}"

echo "${ipns_name}" >"/usr/share/ipns_data/name_$2"
printf 'Published to IPNS %s\n' "${ipns_name}"
