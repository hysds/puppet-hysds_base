FROM docker.io/centos:7

MAINTAINER Gerald Manipon (pymonger) "pymonger@gmail.com"
LABEL description "Base HySDS image"

# Set gosu version
ENV GOSU_VERSION 1.10

# Set user and group
ENV USER ops
ENV GROUP ops

# git url to hysds base puppet module
ENV GIT_URL https://github.com/hysds/puppet-hysds_base/raw/master/install.sh

# provision via puppet
RUN set -ex \
 && yum install -y epel-release \
 && yum update -y \
 && yum install -y \
    puppet puppet-firewalld wget curl git sudo \
 && curl -skL ${GIT_URL} > /tmp/install.sh \
 && chmod 755 /tmp/install.sh \
 && /tmp/install.sh \
 && rm -rf /etc/puppet/modules/* /mnt/swapfile \
 && yum clean all \
 && rm -f /tmp/install.sh \
 && rm -rf /var/cache/yum \
 && gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
 && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64" \
 && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64.asc" \
 && gpg --verify /usr/local/bin/gosu.asc \
 && rm /usr/local/bin/gosu.asc \
 && rm -r /root/.gnupg/ \
 && chmod +x /usr/local/bin/gosu \
 && chmod u+s /usr/local/bin/gosu

# set default user and workdir
USER $USER
WORKDIR /home/$USER

# set entrypoint
COPY docker/docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash", "--login"]
