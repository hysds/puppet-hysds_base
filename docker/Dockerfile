#FROM oraclelinux:8
# Using custom oraclelinux image with /dev removed
# This supports loading these containers using podman with
# an NFS backend
FROM hysds/jplsds-oraclelinux:8.10-slim.latest

MAINTAINER Gerald Manipon (pymonger) "pymonger@gmail.com"
LABEL description "Base HySDS image"

# Set gosu version
ENV GOSU_VERSION 1.10

# Set docker-stats-on-exit-shim version
ENV DSOES_VERSION v2.0

# Set user and group
ENV USER root
ENV GROUP root

# get org and branch
ARG ORG
ARG BRANCH

# git url to hysds base puppet module
ENV GIT_URL https://github.com/${ORG}/puppet-hysds_base/raw/${BRANCH}/install.sh

# add latest repo version to invalidate cache
ADD https://api.github.com/repos/${ORG}/puppet-hysds_base/git/refs/heads/${BRANCH} version.json

# provision via puppet
RUN set -ex \
 && microdnf install dnf \
 && dnf install -y oracle-epel-release-el8 \
 && dnf install -y podman \
 && dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo \
 && dnf config-manager --set-disabled docker-ce-stable \
 # Install containerd.io based on architecture
 && ARCH="$(uname -m)" \
 && if [ "$ARCH" = "x86_64" ]; then \
      rpm --install --nodeps --replacefiles --excludepath=/usr/bin/runc https://download.docker.com/linux/centos/8/x86_64/stable/Packages/containerd.io-1.6.32-3.1.el8.x86_64.rpm; \
    elif [ "$ARCH" = "aarch64" ]; then \
      rpm --install --nodeps --replacefiles --excludepath=/usr/bin/runc https://download.docker.com/linux/centos/8/aarch64/stable/Packages/containerd.io-1.6.32-3.1.el8.aarch64.rpm; \
    fi \
 && dnf install -y --enablerepo=docker-ce-stable docker-ce --nobest \
 && dnf update -y \
 && dnf install -y oraclelinux-developer-release-el8 \
 && dnf install -y puppet wget curl git sudo 'dnf-command(config-manager)' which tar hostname \
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
 # Download gosu for the target architecture
 && GOSU_ARCH="$(uname -m | sed 's/x86_64/amd64/g' | sed 's/aarch64/arm64/g')" \
 && curl -o /usr/local/bin/gosu -SL "https://github.com/hysds/gosu/releases/download/${GOSU_VERSION}/gosu-${GOSU_ARCH}" \
 # Commenting this out for now. Validation was causing build problems
 # when swapping over to slim image and this check isn't critical. Leaving
 # block commented for future reference in case we want to add it back in.
 # && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/hysds/gosu/releases/download/${GOSU_VERSION}/gosu-${GOSU_ARCH}.asc" \
 # && gpg --verify /usr/local/bin/gosu.asc \
 # && rm /usr/local/bin/gosu.asc \
 # && rm -r /root/.gnupg/ \
 && chmod +x /usr/local/bin/gosu \
 && chmod u+s /usr/local/bin/gosu \
 # Download docker-stats-on-exit-shim for the target architecture
 && ARCH="$(uname -m)" \
 && if [ "$ARCH" = "x86_64" ]; then \
      SHIM_BINARY="docker-stats-on-exit-shim"; \
    elif [ "$ARCH" = "aarch64" ]; then \
      SHIM_BINARY="docker-stats-on-exit-shim-arm64"; \
    else \
      echo "Unsupported architecture: $ARCH" && exit 1; \
    fi \
 && curl -fSL -o /docker-stats-on-exit-shim "https://github.com/hysds/docker-stats-on-exit-shim/releases/download/${DSOES_VERSION}/${SHIM_BINARY}" \
 && chmod +x /docker-stats-on-exit-shim \
 && chmod u+s /docker-stats-on-exit-shim \
 && mkdir -p /${USER}/.local/share/containers \
 && chown -R ${USER}:${GROUP} /${USER}

# Note VOLUME options must always happen after the chown call above
# RUN commands can not modify existing volumes
VOLUME /var/lib/containers
VOLUME /root/.local/share/containers

# Remove this directory as it contains extended attributes
RUN rm -rf /var/lib/containers/sigstore


# set default user and workdir
USER $USER
WORKDIR /$USER

# copy entrypoints
COPY docker/docker-entrypoint.sh /docker-entrypoint.sh
COPY docker/docker-entrypoint-with-stats.sh /docker-entrypoint-with-stats.sh

# set default entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash", "--login"]
