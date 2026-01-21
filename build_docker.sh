#!/bin/bash
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <tag> <github org> <github repo branch>"
  echo "e.g.: $0 20170620 hysds master"
  echo "e.g.: $0 latest pymonger develop"
  exit 1
fi
TAG=$1
ORG=$2
BRANCH=$3

# Check if multi-platform build is requested
if [ "${USE_BUILDX}" = "1" ]; then
  echo "Building multi-platform images using Docker Buildx"
  PLATFORM=${DOCKER_BUILDX_PLATFORM:-"linux/amd64,linux/arm64"}
  
  # build base images with buildx
  docker buildx build --platform ${PLATFORM} \
    --progress=plain --build-arg ORG=${ORG} --build-arg BRANCH=${BRANCH} \
    -t hysds/base:${TAG} -f docker/Dockerfile . --push
  
  docker buildx build --platform ${PLATFORM} \
    --progress=plain --build-arg TAG=${TAG} --build-arg ORG=${ORG} \
    --build-arg BRANCH=${BRANCH} -t hysds/cuda-base:${TAG} -f docker/Dockerfile.cuda . --push
else
  echo "Building single-platform images using standard Docker build"
  
  # build base images
  docker build --rm --force-rm --progress=plain --build-arg ORG=${ORG} --build-arg BRANCH=${BRANCH} \
    -t hysds/base:${TAG} -f docker/Dockerfile .
  docker build --rm --force-rm --progress=plain --build-arg TAG=${TAG} --build-arg ORG=${ORG} \
    --build-arg BRANCH=${BRANCH} -t hysds/cuda-base:${TAG} -f docker/Dockerfile.cuda .
fi
