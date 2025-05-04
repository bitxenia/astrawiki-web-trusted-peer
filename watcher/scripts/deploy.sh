#!/bin/sh

# Deploys target directories (both content and service) to IPFS

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

content_cid=$("${SCRIPTS_DIR}/deploy/upload_dir_to_cluster.sh" "$1")
printf 'Added content to cluster with CID %s\n' "${content_cid}"

service_cid=$("${SCRIPTS_DIR}/deploy/upload_file_to_cluster.sh" "$2/service.json")
printf 'Added service.json to cluster with CID %s\n' "${service_cid}"

printf 'Providing service CID %s\n' "${service_cid}"
"${SCRIPTS_DIR}/deploy/provide.sh" "${service_cid}" 'false'
printf 'Providing content CID %s\n' "${content_cid}"
"${SCRIPTS_DIR}/deploy/provide.sh" "${content_cid}" 'true'

"${SCRIPTS_DIR}/deploy/wait_for_peers.sh" "${content_cid}"
printf 'All peers have pinned %s\n' "${content_cid}"

"${SCRIPTS_DIR}/deploy/wait_for_peers.sh" "${service_cid}"
printf 'All peers have pinned %s\n' "${service_cid}"

# Update the IPNS name
content_key_name='content'
service_key_name='service'

"${SCRIPTS_DIR}/deploy/publish_to_ipns.sh" "${content_cid}" "${content_key_name}"
echo 'Content published to IPNS'
"${SCRIPTS_DIR}/deploy/publish_to_ipns.sh" "${service_cid}" "${service_key_name}"
echo 'service.json published to IPNS'

"${SCRIPTS_DIR}/deploy/unpin_old_entries.sh" "${content_cid}" "${service_cid}"
