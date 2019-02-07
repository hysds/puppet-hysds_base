#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <github org>"
  echo "e.g.: $0 hysds"
  echo "e.g.: $0 pymonger"
  exit 1
fi
ORG=$1

mods_dir=/etc/puppet/modules
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
  $git_cmd clone $git_loc $mod_dir
fi


##########################################
# apply
##########################################

$puppet_cmd apply $site_pp
