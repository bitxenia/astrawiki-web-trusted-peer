#!/bin/sh

# Deploys target directories (both content and service) to IPFS

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

CONTENT_CID=$("${SCRIPTS_DIR}/deploy/upload_dir_to_cluster.sh" "$1")
printf 'Added content to cluster with CID %s\n' "${CONTENT_CID}"

SERVICE_CID=$("${SCRIPTS_DIR}/deploy/upload_file_to_cluster.sh" "$2/service.json")
printf 'Added service.json to cluster with CID %s\n' "${SERVICE_CID}"

printf 'Providing service CID %s\n' "${SERVICE_CID}"
"${SCRIPTS_DIR}/deploy/provide.sh" "${SERVICE_CID}" 'false'
printf 'Providing content CID %s\n' "${CONTENT_CID}"
"${SCRIPTS_DIR}/deploy/provide.sh" "${CONTENT_CID}" 'true'

"${SCRIPTS_DIR}/deploy/wait_for_peers.sh" "${CONTENT_CID}"
printf 'All peers have pinned %s\n' "${CONTENT_CID}"

"${SCRIPTS_DIR}/deploy/wait_for_peers.sh" "${SERVICE_CID}"
printf 'All peers have pinned %s\n' "${SERVICE_CID}"

# Update the IPNS name
CONTENT_KEY_NAME='content'
SERVICE_KEY_NAME='service'

"${SCRIPTS_DIR}/deploy/publish_to_ipns.sh" "${CONTENT_CID}" "${CONTENT_KEY_NAME}"
echo 'Content published to IPNS'
"${SCRIPTS_DIR}/deploy/publish_to_ipns.sh" "${SERVICE_CID}" "${SERVICE_KEY_NAME}"
echo 'service.json published to IPNS'

"${SCRIPTS_DIR}/deploy/unpin_old_entries.sh" "${CONTENT_CID}" "${SERVICE_CID}"
