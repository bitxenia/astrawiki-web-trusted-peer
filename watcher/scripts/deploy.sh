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
printf 'All peers have pinned %s' "${CID}"

# Update the IPNS name
"${SCRIPTS_DIR}/deploy/publish_to_ipns.sh" "${CID}"
echo "Published directory to IPNS name"
