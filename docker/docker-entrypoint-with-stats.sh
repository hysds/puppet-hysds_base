#!/bin/bash
set -e

# set HOME explicitly
export HOME=/home/ops

# get group id
GID=$(id -g)

# update user and group ids
#gosu 0:0 groupmod -g $GID ops 2>/dev/null
#gosu 0:0 usermod -u $UID -g $GID ops 2>/dev/null

if id -u "docker" >/dev/null 2>&1; then
  gosu 0:0 usermod -aG docker ops 2>/dev/null
fi

# update ownership
gosu 0:0 chown -R $UID:$GID $HOME 2>/dev/null || true
if [ -f /var/run/docker.sock ]; then
  gosu 0:0 chown -R $UID:$GID /var/run/docker.sock 2>/dev/null || true
fi

# source bash profile
source $HOME/.bash_profile

exec gosu $UID:$GID /docker-stats-on-exit-shim _docker_stats.json "$@"
