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
  $conda_path = '/opt/conda'

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
    'bind-utils': ensure => installed;
    'curl': ensure => installed;
    'wget': ensure => installed;
    'vim-enhanced': ensure => installed;
    'nscd': ensure => installed;
    'chrony': ensure => installed;
    'git': ensure => installed;
    'docker-ce': ensure => installed;
    'yum-utils': ensure => installed;
    'device-mapper-persistent-data': ensure => installed;
    'lvm2': ensure => installed;
    'openssh-server': ensure => installed;
    'cloud-init': ensure => installed;
    'pbzip2': ensure => installed;
    'pigz': ensure => installed;
    'bzip2': ensure => installed;
    'zip': ensure => installed;
    'graphviz': ensure => installed;
    'ImageMagick': ensure => installed;
  }


  #####################################################
  # install anaconda
  #####################################################

  anaconda { "$conda_path":
    path    => $conda_path,
    action  => 'install_miniconda',
  }

  anaconda { 'pin':
    path    => $conda_path,
    action  => 'pin',
    require => Anaconda["$conda_path"],
  }

  anaconda { 'config_show_channel_urls':
    path    => $conda_path,
    action  => 'config',
    args    => '--set show_channel_urls True',
    require => Anaconda['pin'],
  }

  anaconda { 'update_all':
    path    => $conda_path,
    action  => 'update',
    args    => '--all -y',
    require => Anaconda['config_show_channel_urls'],
  }

  anaconda { 'packages':
    path    => $conda_path,
    action  => 'install',
    args    => '-y virtualenv libxml2 libxslt cython cartopy future "setuptools"',
    require => Anaconda['update_all'],
  }

  anaconda { 'clean':
    path    => $conda_path,
    action  => 'clean',
    require => Anaconda['packages'],
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
  # install packages via pip
  #####################################################

  pip { [ 'docker-compose' ]:
    ensure => latest,
    require => Anaconda['clean'],
    notify => Exec['clean_pip_cache'],
  }


  exec { "clean_pip_cache":
    path    => ["/sbin", "/bin", "/usr/bin"],
    command => "rm -rf /root/.cache /home/$user/.cache",
  }


  #####################################################
  # install home baked packages for sciflo and hysds
  #####################################################

  package { 'dbxml':
    provider => rpm,
    ensure   => present,
    source   => "/etc/puppet/modules/hysds_base/files/dbxml-6.1.4-1.x86_64.rpm",
    require  => Anaconda['clean'],
    notify   => Exec['ldconfig'],
  }

  pip { 'bsddb3':
    wheel   => '/etc/puppet/modules/hysds_base/files/bsddb3-6.2.1-cp38-cp38-linux_x86_64.whl',
    ensure  => installed,
    require => [
                Package['dbxml'],
               ],
    notify => Exec['clean_pip_cache'],
  }

  pip { 'dbxml':
    wheel   => '/etc/puppet/modules/hysds_base/files/dbxml-6.1.4-cp38-cp38-linux_x86_64.whl',
    ensure  => installed,
    require => [
                Pip['bsddb3'],
               ],
    notify => Exec['clean_pip_cache'],
  }

}
