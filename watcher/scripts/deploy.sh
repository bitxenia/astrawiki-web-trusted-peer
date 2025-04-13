#!/bin/sh

# Deploys target directory to IPFS

set -e

SCRIPTS_DIR="/usr/local/bin/scripts"
. "${SCRIPTS_DIR}/constants.sh"

# Add target directory to IPFS
CID=$("${SCRIPTS_DIR}/deploy/upload_to_ipfs.sh")
echo "Uploaded to IPFS with CID ${CID}"

# Pin the target directory with IPFS Cluster
"${SCRIPTS_DIR}/deploy/pin_to_cluster.sh" "${CID}"
echo "Pinned directory with IPFS Cluster"

"${SCRIPTS_DIR}/deploy/unpin_old_entries.sh" "${CID}"
"${SCRIPTS_DIR}/deploy/wait_for_peers.sh" "${CID}"
printf 'All peers have pinned %s\n' "${CID}"

# Update the IPNS name
IPNS_NAME=$("${SCRIPTS_DIR}/deploy/publish_to_ipns.sh" "${CID}")
printf 'Published directory to IPNS name %s\n' "${IPNS_NAME}"
