#!/bin/sh

set -e

IPNS_KEYS_DIR='./ipns_keys'

if [ ! -f "./.env" ]; then
	echo ".env not found, creating..."
	touch .env

	printf 'Generate cluster identity? y/n: '
	read -r identity_needed
	echo "# IPFS Cluster configuration" >>.env
	if [ "${identity_needed}" = "y" ]; then
		RESPONSE=$(./scripts/generate_identity.sh)

		echo "${RESPONSE}" | grep 'PeerId' | cut -d' ' -f2 | xargs printf 'PEER_ID=%s\n' >>.env
		echo "${RESPONSE}" | grep 'PrivKey' | cut -d' ' -f2 | xargs printf 'PRIV_KEY=%s\n' >>.env
		echo "Identity variables added to .env!"
	else
		echo "PEER_ID=" >>.env
		echo "PRIV_KEY=" >>.env
		echo "⚠️ Identity variables generation skipped. Add your own later (check README), otherwise the trusted peer will not run."
	fi

	echo "# Content configuration" >>.env
	# Content repo
	printf 'Input the git repository for the content (default: https://github.com/bitxenia/astrawiki-web.git): '
	read -r content_repo
	if [ -z "${content_repo}" ]; then
		content_repo='https://github.com/bitxenia/astrawiki-web.git'
	fi
	printf 'CONTENT_GIT_ADDRESS=%s\n' "${content_repo}" >>.env

	# Content branch
	printf 'Input the git branch for the content (default: page-build): '
	read -r content_branch
	if [ -z "${content_branch}" ]; then
		content_branch='page-build'
	fi
	printf 'CONTENT_GIT_BRANCH=%s\n' "${content_branch}" >>.env

	echo "# service.json configuration" >>.env
	# Service repo
	printf 'Input the git repository for the service.json file (default: https://github.com/bitxenia/astrawiki-web-service.git): '
	read -r service_repo
	if [ -z "${service_repo}" ]; then
		service_repo='https://github.com/bitxenia/astrawiki-web.git'
	fi
	printf 'SERVICE_GIT_ADDRESS=%s\n' "${service_repo}" >>.env

	# Service branch
	printf 'Input the git branch for the service.json file (default: main): '
	read -r content_branch
	if [ -z "${service_branch}" ]; then
		service_branch='main'
	fi
	printf 'SERVICE_GIT_BRANCH=%s\n' "${service_branch}" >>.env

	echo ".env created!"

fi

if [ ! -d "${IPNS_KEYS_DIR}" ] || [ ! -f "${IPNS_KEYS_DIR}/content.key" ] || [ ! -f "${IPNS_KEYS_DIR}/service.key" ]; then
	echo "IPNS keys not found"
	printf 'Generate new IPFS Cluster keys? y/n: '
	read -r keys_needed
	if [ "${keys_needed}" = "y" ]; then
		./scripts/generate_ipns_keys.sh
		echo "Keys generated in ./ipns_keys"
	else
		mkdir -p ./ipns_keys
		echo "⚠️ Keys generation skipped. Add your own later (check README), otherwise the trusted peer won't run"
	fi
fi

echo "✅ Configuration initialized"
