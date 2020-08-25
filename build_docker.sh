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

# pull latest version of base images
docker pull hysds/centos:7 || exit 1
docker tag hysds/centos:7 docker.io/centos:latest || exit 1
docker pull nvidia/cuda:9.2-runtime-centos7 || exit 1
docker tag nvidia/cuda:9.2-runtime-centos7 nvidia/cuda:latest || exit 1

# build base images
docker build --rm --force-rm --build-arg ORG=${ORG} --build-arg BRANCH=${BRANCH} \
  -t hysds/base:${TAG} -f docker/Dockerfile .
docker build --rm --force-rm --build-arg ORG=${ORG} --build-arg BRANCH=${BRANCH} \
  -t hysds/cuda-base:${TAG} -f docker/Dockerfile.cuda .
