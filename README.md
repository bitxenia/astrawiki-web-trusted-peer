# Astrawiki Trusted Peer

This is a trusted peer for Astrawiki. It enables designated users to update the
content that a wiki's IPNS points to whenever changes occur. Also, the trusted
peer includes all the features of a collaborative peer. That means it
can:

- Pin existing and newly created articles in a given wiki.
- Pin frontend files via IPFS Cluster and update the corresponding IPNS entry.

## Prerequisites

Users should be familiar with both IPFS and IPFS Clusters, and have a basic
understanding of Docker and Docker Compose.

## Dependencies

This repository requires the following dependencies:

- `make`: executes the different available commands.
- `docker`: runs the Kubo and IPFS Cluster containers.
- `docker-compose`: used to manage the containers.
- `python3`: required for some scripts.

## Installation

1. Clone the repository using
   `git clone git@github.com:bitxenia/astrawiki-web-trusted-peer.git`

2. Create a `.env` file based on the `.env.example` file.

## Required environment variables

- `PEER_ID` and `PRIV_KEY`: these variables determine the Kubo node's identity.
  Every trusted peer should have the same identity variables.
- `ID` and `PRIVATE_KEY`: [TODO]
- `GIT_REPO_WEB_SSH_URL`: SSH URL used to clone and manage the frontend's code.

## Usage

### `make up`

Builds and runs the Kubo node and the IPFS Cluster container in the background.

### `make down`

Kills the running containers.

### `make logs`

Shows the log entries in both containers.

### `make generate_ipfs_keys`

Generates `PEER_ID` and `PRIV_KEY` values. Users creating a new network of
trusted peers for their wiki should run this once and then copy the values
across all trusted peers.

## Technical overview

[TODO]

## Contributing

Contributions are welcome in the form of new issues and pull requests.

## License

MIT (LICENSE-MIT / http://opensource.org/licenses/MIT)

