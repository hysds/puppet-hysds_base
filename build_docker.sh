#!/bin/bash
if [ "$#" -ne 1 ]; then
  echo "Enter tag as arg: $0 <tag>"
  echo "e.g.: $0 20170620"
  echo "e.g.: $0 latest"
  exit 1
fi
TAG=$1

# pull latest version of base images
docker pull docker.io/centos:7 || exit 1
docker tag docker.io/centos:7 docker.io/centos:latest || exit 1
docker pull nvidia/cuda:9.2-runtime-centos7 || exit 1
docker tag nvidia/cuda:9.2-runtime-centos7 nvidia/cuda:latest || exit 1

# build base images
docker build --rm --force-rm -t hysds/base:${TAG} -f docker/Dockerfile .
docker build --rm --force-rm -t hysds/cuda-base:${TAG} -f docker/Dockerfile.cuda .
