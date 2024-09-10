#####################################################
# hysds_base class
#####################################################

class hysds_base {

  #####################################################
  # create groups and users
  #####################################################
  
  $root_user = 'root'
  $root_group = 'root'
  $ops_user = 'ops'
  $ops_group = 'ops'
  $conda_path = '/opt/conda'

  group { $root_group:
    ensure     => present,
  }

  user { $root_user:
    ensure     => present,
    gid        => $root_group,
    shell      => '/bin/bash',
    home       => "/$root_user",
    managehome => true,
    require    => [
                   Group[$root_group],
                  ],
  }

  file { "/$root_user":
    ensure  => directory,
    owner   => $root_user,
    group   => $root_group,
    mode    => "0755",
    require => User[$root_user],
  }

  file { "/etc/sudoers.d/90-cloudimg-$root_user":
    ensure  => file,
    content  => template('hysds_base/90-cloudimg-user'),
    mode    => "0440",
    require => [
                User[$root_user],
               ],
  }

  group { $ops_group:
    ensure     => present,
  }

  user { $ops_user:
    ensure     => present,
    gid        => $ops_group,
    shell      => '/bin/bash',
    home       => "/home/$ops_user",
    managehome => true,
    require    => [
                   Group[$ops_group],
                  ],
  }

  file { "/home/$ops_user":
    ensure  => directory,
    owner   => $ops_user,
    group   => $ops_group,
    mode    => "0755",
    require => User[$ops_user],
  }

  file { "/etc/sudoers.d/90-cloudimg-$ops_user":
    ensure  => file,
    content  => template('hysds_base/90-cloudimg-user'),
    mode    => "0440",
    require => [
                User[$ops_user],
               ],
  }

  #####################################################
  # add .inputrc to users' home
  #####################################################

  #hysds_base::inputrc { 'root':
  #  home => '/root',
  #}
  
  hysds_base::inputrc { $root_user:
    home    => "/$root_user",
    require => User[$root_user],
  }

  hysds_base::inputrc { $ops_user:
    home    => "/home/$ops_user",
    require => User[$ops_user],
  }

  #####################################################
  # change default user
  #####################################################

  file_line { "default_user":
    ensure  => present,
    line    => "    name: $root_user",
    path    => "/etc/cloud/cloud.cfg",
    match   => "^    name:",
    require => [
                User[$root_user],
                Package['cloud-init'],
               ],
  }


  #####################################################
  # disable SELinux
  #####################################################

  #file_line { "disable_selinux":
  #  ensure  => present,
  #  line    => "SELINUX=disabled",
  #  path    => "/etc/selinux/config",
  #  match   => "^SELINUX=",
  #}

  file { "/etc/selinux/config":
    ensure  => present,
    mode    => "0644",
    content => "SELINUX=disabled\n",
  }


  #####################################################
  # install .bashrc
  #####################################################

  file { "/$root_user/.bashrc":
    ensure  => present,
    content => template('hysds_base/bashrc'),
    owner   => $root_user,
    group   => $root_group,
    mode    => "0644",
    require => User[$root_user],
  }

  file { "/home/$ops_user/.bashrc":
    ensure  => present,
    content => template('hysds_base/bashrc'),
    owner   => $ops_user,
    group   => $ops_group,
    mode    => "0644",
    require => User[$ops_user],
  }

 # file { "/root/.bashrc":
 #   ensure  => present,
 #   content => template('hysds_base/bashrc'),
 #   mode    => "0600",
 # }


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
    'libnsl': ensure => installed;
    'libselinux-utils': ensure => installed;
  }


  #####################################################
  # install anaconda
  #####################################################

  hysds_base::anaconda { "$conda_path":
    path    => $conda_path,
    action  => 'install_miniconda',
  }

  hysds_base::anaconda { 'pin':
    path    => $conda_path,
    action  => 'pin',
    require => Hysds_base::Anaconda["$conda_path"],
  }

  hysds_base::anaconda { 'config_show_channel_urls':
    path    => $conda_path,
    action  => 'config',
    args    => '--set show_channel_urls True',
    require => Hysds_base::Anaconda['pin'],
  }

  hysds_base::anaconda { 'update_all':
    path    => $conda_path,
    action  => 'update',
    args    => '--all -y',
    require => Hysds_base::Anaconda['config_show_channel_urls'],
  }

  hysds_base::anaconda { 'packages':
    path    => $conda_path,
    action  => 'install',
    args    => '-y virtualenv libxml2 libxslt cython cartopy future setuptools',
    require => Hysds_base::Anaconda['update_all'],
  }

  hysds_base::anaconda { 'clean':
    path    => $conda_path,
    action  => 'clean',
    require => Hysds_base::Anaconda['packages'],
  }
  

  #####################################################
  # link vim
  #####################################################
  
  hysds_base::update_alternatives { 'vi':
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
    owner   => $ops_user,
    group   => $ops_group,
    mode    => "0775",
  }


  #####################################################
  # install packages via pip
  #####################################################

  exec { "clean_pip_cache":
    path    => ["/sbin", "/bin", "/usr/bin"],
    command => "rm -rf /$root_user/.cache /$root_user/.cache /home/$ops_user/.cache",
  }


  #####################################################
  # install home baked packages for sciflo and hysds
  #####################################################

  package { 'dbxml':
    provider => rpm,
    ensure   => present,
    source   => "/etc/puppetlabs/code/modules/hysds_base/files/dbxml-6.1.4-1.x86_64.rpm",
    require  => Hysds_base::Anaconda['clean'],
    notify   => Exec['ldconfig'],
  }

  hysds_base::pip { 'bsddb3':
    wheel   => '/etc/puppetlabs/code/modules/hysds_base/files/bsddb3-6.2.1-cp39-cp39-linux_x86_64.whl',
    ensure  => installed,
    require => [
                Package['dbxml'],
               ],
    notify => Exec['clean_pip_cache'],
  }

  hysds_base::pip { 'dbxml':
    wheel   => '/etc/puppetlabs/code/modules/hysds_base/files/dbxml-6.1.4-cp39-cp39-linux_x86_64.whl',
    ensure  => installed,
    require => [
                Hysds_base::Pip['bsddb3'],
               ],
    notify => Exec['clean_pip_cache'],
  }

}
