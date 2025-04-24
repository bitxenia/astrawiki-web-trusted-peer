#!/bin/sh

set -e

KEYS_DIR='./configuration/ipns_keys'
CONTENT_KEY_NAME='content.key'
SERVICE_KEY_NAME='service.key'
DATA_DIR='./data/ipns_data/ipns_keys'

if [ ! -d "${KEYS_DIR}" ] || [ ! -f "${KEYS_DIR}/${CONTENT_KEY_NAME}" ] || [ ! -f "${KEYS_DIR}/${SERVICE_KEY_NAME}" ]; then
	echo "No IPNS keys found in ${KEYS_DIR}."
	echo "If making a new cluster, create a pair with make ipns_keys"
	exit 1
fi

mkdir -p "${DATA_DIR}"
cp "${KEYS_DIR}/${CONTENT_KEY_NAME}" "${DATA_DIR}"
cp "${KEYS_DIR}/${SERVICE_KEY_NAME}" "${DATA_DIR}"
