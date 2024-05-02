FROM oraclelinux:8

MAINTAINER Gerald Manipon (pymonger) "pymonger@gmail.com"
LABEL description "Base HySDS image"

# Set gosu version
ENV GOSU_VERSION 1.10

# Set docker-stats-on-exit-shim version
ENV DSOES_VERSION v1.0

# Set user and group
ENV USER ops
ENV GROUP ops

# get org and branch
ARG ORG
ARG BRANCH

# git url to hysds base puppet module
ENV GIT_URL https://github.com/${ORG}/puppet-hysds_base/raw/${BRANCH}/install.sh

# add latest repo version to invalidate cache
ADD https://api.github.com/repos/${ORG}/puppet-hysds_base/git/refs/heads/${BRANCH} version.json

# provision via puppet
RUN set -ex \
 && dnf install -y oracle-epel-release-el8 \
 && dnf install podman \
 && dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo \
 && dnf config-manager --set-disabled docker-ce-stable \
 && rpm --install --nodeps --replacefiles --excludepath=/usr/bin/runc https://download.docker.com/linux/centos/8/x86_64/stable/Packages/containerd.io-1.4.9-3.1.el8.x86_64.rpm \
 && dnf install --enablerepo=docker-ce-stable docker-ce --nobest \
 && dnf update -y \
 && dnf install -y \
    puppet wget curl git sudo 'dnf-command(config-manager)' which tar hostname \
 && curl -skL ${GIT_URL} > /tmp/install.sh \
 && chmod 755 /tmp/install.sh \
 && /tmp/install.sh ${ORG} ${BRANCH} \
 && rm -rf /etc/puppetlabs/code/modules/* /mnt/swapfile \
 && dnf clean all \
 && rm -f /tmp/install.sh \
 && rm -rf /var/cache/dnf \
 # Commenting out for now as we are consistently getting
 # the following error: gpg: keyserver receive failed: Server indicated a failure
 # && for server in ha.pool.sks-keyservers.net \
 #     hkp://p80.pool.sks-keyservers.net:80 \
 #     keyserver.ubuntu.com \
 #     hkp://keyserver.ubuntu.com:80 \
 #     keyserver.pgp.com \
 #     pgp.mit.edu; do \
 #     gpg --keyserver "$server" --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && break || : ; \
 #   done \
 && curl -o /usr/local/bin/gosu -SL "https://github.com/hysds/gosu/releases/download/${GOSU_VERSION}/gosu-amd64" \
 && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/hysds/gosu/releases/download/${GOSU_VERSION}/gosu-amd64.asc" \
 #&& gpg --verify /usr/local/bin/gosu.asc \
 && rm /usr/local/bin/gosu.asc \
 #&& rm -r /root/.gnupg/ \
 && chmod +x /usr/local/bin/gosu \
 && chmod u+s /usr/local/bin/gosu \
 && curl -o /docker-stats-on-exit-shim -SL "https://github.com/hysds/docker-stats-on-exit-shim/releases/download/${DSOES_VERSION}/docker-stats-on-exit-shim" \
 && chmod +x /docker-stats-on-exit-shim \
 && chmod u+s /docker-stats-on-exit-shim \
 && mkdir -p /home/${USER}/.local/share/containers \
 && chown -R ${USER}:${USER} /home/${USER}

# Note VOLUME options must always happen after the chown call above
# RUN commands can not modify existing volumes
VOLUME /var/lib/containers
VOLUME /home/ops/.local/share/containers

# set default user and workdir
USER $USER
WORKDIR /home/$USER

# copy entrypoints
COPY docker/docker-entrypoint.sh /docker-entrypoint.sh
COPY docker/docker-entrypoint-with-stats.sh /docker-entrypoint-with-stats.sh

# set default entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash", "--login"]
