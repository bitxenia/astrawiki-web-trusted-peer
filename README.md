# Trusted peer

Trusted peer is a tool for deploying and continuously updating a static website
on IPFS across multiple nodes, while preserving a consistent access address. It
enables any community to manage their website in a decentralized,
community-driven approach.

## Motivation

This project streamlines the process of publishing a website to IPFS across
multiple peers. While clusters can handle this, they require manually updating
the IPNS entry with new content, while this eliminates the manual step and
automatically builds the content on top.

## Features

- Publishes static websites without server-centric infrastructure needed.
- Keeps the website in sync with its git repository to maintain the CI/CD
  workflow from traditional web development.
- Enables trusted community members to help host the website.
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

## Installation

1. Clone the repository:

   ```sh
   git clone git@github.com:bitxenia/astrawiki-web-trusted-peer.git
   ```

2. Run `make init` to get started.

## Required environment variables

- `ID` and `PRIVATE_KEY`: ID fields for the Cluster node.
- `CONTENT_GIT_ADDRESS`: SSH or HTTPS address used to clone and manage the
  content's source code.
- `CONTENT_GIT_BRANCH`: name of the website's repo's main branch.
- `BUILD_DIR`: stores the build static website files.

## Usage

### `make init`

Generates initial configuration.

### `make up`

Builds and runs the Kubo node, the IPFS Cluster container, and the git watcher
service in the background.

### `make down`

Kills the running services.

### `make logs`

Shows the log entries in both containers.

### `make identity`

Generates `PEER_ID` and `PRIV_KEY` values. Users creating a new network of
trusted peers for their wiki should run this once and then copy the values
across all trusted peers.

### `make ipns_keys`

Generates two IPNS private keys

## Technical overview

### IPNS

IPNS is useful for keeping content reachable through a persistent CID, even
when the content changes. This is ideal for pointing a web address to the IPNS
entry, because it means the address doesn't have to change each time the
content does.

While this is an excellent feature, it lacks the ability to have
multiple peers manage the same IPNS pointer. Because of that limitation, IPFS
has to treat all the trusted Kubo nodes as the same node. Sharing a `PeerID`
and `PrivKey` solves this, as it means all the trusted peers have the same
identity and thus can update the IPNS pointer.

## Cluster

[TODO]

### Watcher

[TODO]

## Limitations

- This project works exclusively for websites built using npm. Generalizing it to
  work with any kind of project _might_ be included in the future.

**Note:** the design of this project works with not just websites, but any kind of
document library. An npm project still needs to be present though.

- The git repo should be public, there's currently no way to grant the watcher
  container access to an SSH key.

## Contributing

Contributions are welcome in the form of new issues and pull requests.

## License

MIT (LICENSE-MIT / http://opensource.org/licenses/MIT)
