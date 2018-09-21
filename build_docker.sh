#!/bin/bash
docker build --rm --force-rm -t hysds/base:latest -f docker/Dockerfile .
