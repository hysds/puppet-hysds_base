#!/bin/bash
set -e

# set HOME explicitly
export HOME=/root

# get group id
GID=$(id -g)

# ordering of these groupmod/usermod calls is important

# update user and group ids
#if [ -e /var/run/docker.sock ]; then
  # These groupmod/usermod commands are needed in order to start up httpd under sudo
#  gosu 0:0 groupmod -g $GID ops 2>/dev/null
#  gosu 0:0 usermod -u $UID -g $GID ops 2>/dev/null
  # FIXME: Unsure if I should wrap this in an "if id -u "docker" >/dev/null 2>&1; then" clause
  # instead
#  gosu 0:0 usermod -aG docker ops 2>/dev/null
#fi

# update ownership
#gosu 0:0 chown -R $UID:$GID $HOME 2>/dev/null || true

#if [ -e /var/run/docker.sock ]; then
#  gosu 0:0 chown -R $UID:$GID /var/run/docker.sock 2>/dev/null || true
#else
  # Assume podman
  # We need to give sudo priviliges to start up httpd to the host user
#  if [[ ! -z "$HOST_USER" ]]; then
#    gosu 0:0 su root -c "chmod u+w /etc/sudoers.d/90-cloudimg-ops"
#    gosu 0:0 su root -c "echo '${HOST_USER} ALL=NOPASSWD: /usr/sbin/apachectl' >> /etc/sudoers.d/90-cloudimg-ops"
#    gosu 0:0 su root -c "chmod u-w /etc/sudoers.d/90-cloudimg-ops"
#  fi
#fi

# source bash profile
source $HOME/.bash_profile

exec gosu $UID:$GID "$@"
