# Trusted peer

Trusted peer is a tool for deploying and continuously updating a static website
on IPFS across multiple nodes, while preserving a consistent access address. It
enables any community to manage their website in a decentralized,
community-driven approach.

## Motivation

This project was created to streamline the process of publishing a website to
IPFS across multiple peers. This could be done using clusters, but it meant
that upon new changes, pointing the IPNS entry to the new content was done
manually. This removes the need for that added manual step, and automates the
building of the content on top.

## Features

- Publishes static websites without server-centric infrastructure needed.
- Keeps the website in sync with its git repository to maintain the CI/CD
  workflow from traditional web development.
- Allows trusted community members to help host the website.
- Hosts bitxenia's Astrawiki by default.

## Prerequisites

Users should be familiar with [IPFS](https://docs.ipfs.tech/),
[IPNS](https://docs.ipfs.tech/concepts/ipns/) and
[IPFS Clusters](https://ipfscluster.io/documentation/), and have a basic
understanding of [Docker](https://docs.docker.com/) and
[Docker Compose](https://docs.docker.com/compose/).

## Dependencies

This repository requires the following dependencies:

- `make`: executes the different available commands.
- `docker`: runs the Kubo and IPFS Cluster containers.
- `docker-compose`: used to manage the containers.
- `python3`: required for some scripts.

## Installation

1. Clone the repository:

   ```sh
   git clone git@github.com:bitxenia/astrawiki-web-trusted-peer.git
   ```

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

### `make identity`

Generates `PEER_ID` and `PRIV_KEY` values. Users creating a new network of
trusted peers for their wiki should run this once and then copy the values
across all trusted peers.

## Technical overview

[TODO]

## Contributing

Contributions are welcome in the form of new issues and pull requests.

## License

MIT (LICENSE-MIT / http://opensource.org/licenses/MIT)
