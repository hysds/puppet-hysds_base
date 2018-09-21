# HySDS base

Puppet module to install all dependencies needed for HySDS.

## Prerequisites
Create a base CentOS7 image as described [here](https://github.com/hysds/hysds-framework/wiki/Puppet-Automation#create-a-base-centos-7-image-for-installation-of-all-hysds-component-instances).

## VM/Bare-metal Installation
As _root_ run:
```
bash < <(curl -skL https://github.com/hysds/puppet-hysds_base/raw/master/install.sh)
```

## Build Docker image
```
./build_docker.sh
```
