# HySDS base

Puppet module to install all dependencies needed for HySDS.

## Prerequisites
Create a base CentOS7 image as described [here](https://github.com/hysds/hysds-framework/wiki/Puppet-Automation#create-a-base-centos-7-image-for-installation-of-all-hysds-component-instances).

## VM/Bare-metal Installation
As _root_ run:
```
cd /etc/puppetlabs/code/modules
git clone https://github.com/hysds/puppet-hysds_base.git hysds_base
cd hysds_base
./install.sh <github org> <branch>
```

## Build Docker images based on CentOS and CUDA images
```
./build_docker.sh <tag> <github org> <github repo branch>
```
