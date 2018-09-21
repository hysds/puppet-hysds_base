#####################################################
# hysds_base class
#####################################################

class hysds_base {

  #####################################################
  # create groups and users
  #####################################################
  
  $user = 'ops'
  $group = 'ops'
  $docker_group = 'docker'

  group { $group:
    ensure     => present,
  }

  user { $user:
    ensure     => present,
    gid        => $group,
    groups     => [ $docker_group ],
    shell      => '/bin/bash',
    home       => "/home/$user",
    managehome => true,
    require    => [
                   Group[$group],
                  ],
  }

  file { "/home/$user":
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => 0755,
    require => User[$user],
  }

  file { "/etc/sudoers.d/90-cloudimg-$user":
    ensure  => file,
    content  => template('hysds_base/90-cloudimg-user'),
    mode    => 0440,
    require => [
                User[$user],
               ],
  }


  #####################################################
  # add .inputrc to users' home
  #####################################################

  inputrc { 'root':
    home => '/root',
  }
  
  inputrc { $user:
    home    => "/home/$user",
    require => User[$user],
  }


  #####################################################
  # change default user
  #####################################################

  file_line { "default_user":
    ensure  => present,
    line    => "    name: $user",
    path    => "/etc/cloud/cloud.cfg",
    match   => "^    name:",
    require => User[$user],
  }


  #####################################################
  # disable SELinux
  #####################################################

  file_line { "disable_selinux":
    ensure  => present,
    line    => "SELINUX=disabled",
    path    => "/etc/selinux/config",
    match   => "^SELINUX=",
  }


  #####################################################
  # install .bashrc
  #####################################################

  file { "/home/$user/.bashrc":
    ensure  => present,
    content => template('hysds_base/bashrc'),
    owner   => $user,
    group   => $group,
    mode    => 0644,
    require => User[$user],
  }

  file { "/root/.bashrc":
    ensure  => present,
    content => template('hysds_base/bashrc'),
    mode    => 0600,
  }


  #####################################################
  # install packages
  #####################################################

  package {
    'sudo': ensure => installed;
    'screen': ensure => installed;
    'bind-utils': ensure => installed;
    'curl': ensure => installed;
    'wget': ensure => installed;
    'vim-enhanced': ensure => installed;
    'nscd': ensure => installed;
    'chrony': ensure => installed;
    'git': ensure => installed;
    'subversion': ensure => installed;
    'docker-ce': ensure => installed;
    'yum-utils': ensure => installed;
    'device-mapper-persistent-data': ensure => installed;
    'lvm2': ensure => installed;
    'firewalld': ensure => installed;
    'openssh-server': ensure => installed;
    'cloud-init': ensure => installed;
    'pbzip2': ensure => installed;
    'pigz': ensure => installed;
    'bzip2': ensure => installed;
    'zip': ensure => installed;
    'graphviz': ensure => installed;
    'ImageMagick': ensure => installed;
    'python': ensure => present;
    'python-setuptools': ensure => present;
    'python2-pip': ensure => present;
    'python-virtualenv': ensure => present;
    'libxml2-python': ensure => installed;
    'libxslt-python': ensure => installed;
    'python-pillow': ensure => installed;
    'python-formencode': ensure => installed;
    'python-sqlalchemy': ensure => installed;
    'python-sqlobject': ensure => installed;
    'SOAPpy': ensure => installed;
    'python-twisted-core': ensure => installed;
    'python-twisted-web': ensure => installed;
    'python-twisted-words': ensure => installed;
  }


  #####################################################
  # link vim
  #####################################################
  
  update_alternatives { 'vi':
    link     => '/bin/vi',
    path     => '/bin/vim',
    priority => 1,
    require  => Package['vim-enhanced'],
  }


  #####################################################
  # refresh ld cache
  #####################################################

  if ! defined(Exec['ldconfig']) {
    exec { 'ldconfig':
      command     => '/sbin/ldconfig',
      refreshonly => true,
    }
  }
  

  #####################################################
  # link sciflo data area
  #####################################################
  
  file { '/data':
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => 0775,
  }


  #####################################################
  # install home baked packages for sciflo and hysds
  #####################################################

  package { 'hdfeos':
    provider => rpm,
    ensure   => present,
    source   => "/etc/puppet/modules/hysds_base/files/hdfeos-2.19-1.x86_64.rpm",
    notify   => Exec['ldconfig'],
  }

  package { 'dbxml':
    provider => rpm,
    ensure   => present,
    source   => "/etc/puppet/modules/hysds_base/files/dbxml-6.0.18-1.x86_64.rpm",
    require  => Package['libxml2-python'],
    notify   => Exec['ldconfig'],
  }

  easy_install { 'bsddb3':
    name    => '/etc/puppet/modules/hysds_base/files/bsddb3-6.1.0-py2.7-linux-x86_64.egg',
    ensure  => installed,
    require => [
                Package['python-setuptools'],
                Package['dbxml'],
               ],
  }

  easy_install { 'python-dbxml':
    name    => '/etc/puppet/modules/hysds_base/files/dbxml-6.0.18-py2.7-linux-x86_64.egg',
    ensure  => installed,
    require => [
                Package['python-setuptools'],
                Package['dbxml'],
                Easy_install['bsddb3'],
               ],
  }

  easy_install { 'python-pyxml':
    name    => '/etc/puppet/modules/hysds_base/files/PyXML-0.8.4-py2.7-linux-x86_64.egg',
    ensure  => installed,
    require => Package['python-setuptools'],
  }
  
  easy_install { 'python-numeric':
    name    => '/etc/puppet/modules/hysds_base/files/Numeric-24.2-py2.7-linux-x86_64.egg',
    ensure  => installed,
    require => Easy_install['python-pyxml'],
  }

  easy_install { 'python-hdfeos':
    name    => '/etc/puppet/modules/hysds_base/files/hdfeos-0.5-py2.7-linux-x86_64.egg',
    ensure  => installed,
    require => Easy_install['python-numeric'],
  }

  easy_install { 'python-polygon':
    name    => '/etc/puppet/modules/hysds_base/files/Polygon-1.13-py2.7-linux-x86_64.egg',
    ensure  => installed,
    require => Easy_install['python-hdfeos'],
  }

  easy_install { 'python-numarray':
    name    => '/etc/puppet/modules/hysds_base/files/numarray-1.5.2-py2.7-linux-x86_64.egg',
    ensure  => installed,
    require => Easy_install['python-polygon'],
  }

  easy_install { 'python-pyhdf':
    name    => '/etc/puppet/modules/hysds_base/files/pyhdf-0.8.3-py2.7-linux-x86_64.egg',
    ensure  => installed,
    require => Easy_install['python-numarray'],
  }

  easy_install { 'python-processing':
    name    => '/etc/puppet/modules/hysds_base/files/processing-0.39-py2.7-linux-x86_64.egg',
    ensure  => installed,
    require => Package['python-setuptools'],
  }


}
