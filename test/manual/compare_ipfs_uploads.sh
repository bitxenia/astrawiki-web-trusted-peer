#!/bin/sh

# Used to check if there's a discrepancy between the container and the host
# when adding a directory to IPFS. Modify the entrypoint in the container to
# run test in the container. Make IS_CONTAINER false and run it locally to
# get the local results.

IS_CONTAINER=true
KUBO_API_ADDRESS="http://ipfs_node:5001/api/v0"

git clone --quiet "https://github.com/bitxenia/astrawiki-web.git"

if [ "${IS_CONTAINER}" = false ]; then
	docker run --quiet -d --name ipfs_host -v "./data/staging":/export -v "./data/ipfs:/data/ipfs" -p 4001:4001 -p 4001:4001/udp -p 127.0.0.1:8080:8080 -p 127.0.0.1:5001:5001 ipfs/kubo:v0.34.1
	KUBO_API_ADDRESS="http://localhost:5001/api/v0"
fi

cd astrawiki-web || exit 1
# find ./out -type f | sort

TMP_FORM="/tmp/ipfs_upload_form.$$"

on_exit() {
	if [ "$IS_CONTAINER" = true ]; then
		docker remove ipfs_host
	fi

	cd ..
	rm -rf astrawiki-web
	rm -f "${TMP_FORM}"
}

trap on_exit EXIT

# Build the curl -F args dynamically
touch "$TMP_FORM"

TARGET_DIR="./out"
find "$TARGET_DIR" -type f | sort | while IFS= read -r file; do
	RELPATH="out/${file#$TARGET_DIR/}"
	printf '%s\n' "-F \"file=@${file};filename=${RELPATH}\"" >>"$TMP_FORM"
done

# Check until Kubo container is up
while :; do
	STATUS=$(curl -o /dev/null -w "%{http_code}" -s -X POST "${KUBO_API_ADDRESS}/id" || echo 0)
	if [ "${STATUS}" = 200 ]; then
		break
	fi
	sleep 1
done

# Combine curl command and eval
CMD="curl -s -X POST '${KUBO_API_ADDRESS}/add?recursive=true&wrap-with-directory=true'"

# Append each form line from the temp file
while IFS= read -r line; do
	CMD="$CMD $line"
done <"$TMP_FORM"

# Eval the full curl command and output CID
eval "${CMD}"
