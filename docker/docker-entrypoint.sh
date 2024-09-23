#!/bin/bash
set -e

# set HOME explicitly
export HOME=/root

# get group id
GID=$(id -g)

if [ -e /var/run/docker.sock ]; then
  gosu 0:0 chown -R $UID:$GID /var/run/docker.sock 2>/dev/null || true
fi

# source bash profile
source $HOME/.bash_profile

exec gosu $UID:$GID "$@"
