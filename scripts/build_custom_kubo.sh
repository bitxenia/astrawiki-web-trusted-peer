#!/bin/bash

# Set image name and tag
IMAGE_NAME="custom_kubo"
TAG="v0.34.1"

# Build the Docker image
docker build -t ${IMAGE_NAME}:${TAG} -f configuration/kubo_config/Dockerfile .

mkdir -p ./data/ipfs_data
sudo chown -R 1000:1000 ./data/ipfs_data

# Check if build succeeded
if [ $? -eq 0 ]; then
  echo "Successfully built ${IMAGE_NAME}:${TAG}"
else
  echo "Failed to build ${IMAGE_NAME}:${TAG}"
  exit 1
fi