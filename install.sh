#!/bin/bash
set -e

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <github org> <branch>"
  echo "e.g.: $0 hysds master"
  echo "e.g.: $0 hysds python2"
  echo "e.g.: $0 pymonger python3"
  exit 1
fi
ORG=$1
BRANCH=$2

mods_dir=/etc/puppetlabs/code/modules
cd $mods_dir

##########################################
# need to be root
##########################################

id=`whoami`
if [ "$id" != "root" ]; then
  echo "You must be root to run this script."
  exit 1
fi


##########################################
# check that puppet and git is installed
##########################################

git_cmd=`which git`
if [ $? -ne 0 ]; then
  echo "Git must be installed. Run 'yum install git'."
  exit 1
fi

puppet_cmd=`which puppet`
if [ $? -ne 0 ]; then
  echo "Puppet must be installed. Run 'yum install puppet'."
  exit 1
fi


##########################################
# set git url
##########################################

git_url="https://github.com"


##########################################
# install puppetlab's stdlib module
##########################################

mod_dir=$mods_dir/stdlib

# check that module is here; if not, export it
if [ ! -d $mod_dir ]; then
  $puppet_cmd module install puppetlabs-stdlib
fi


##########################################
# export hysds_base puppet module
##########################################

git_loc="${git_url}/${ORG}/puppet-hysds_base"
mod_dir=$mods_dir/hysds_base
site_pp=$mod_dir/site.pp

# check that module is here; if not, export it
if [ ! -d $mod_dir ]; then
  $git_cmd clone --single-branch -b $BRANCH $git_loc $mod_dir
fi


##########################################
# apply
##########################################

$puppet_cmd apply $site_pp
