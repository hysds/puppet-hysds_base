define hysds_base::anaconda($path='/opt/conda', $action=install_miniconda, $args='') {
  case $action {
    install_miniconda: {
      exec { "install_anaconda":
        path    => "/usr/local/bin:/usr/bin:/bin",
        command => "/tmp/miniconda.sh -b -p $path",
        creates => $path,
        require => File["/tmp/miniconda.sh"],
        notify  => Exec["remove_installer"],
      }

      exec { "download_installer":
        path    => "/usr/local/bin:/usr/bin:/bin",
        command => "curl -sSL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh",
        creates => "/tmp/miniconda.sh", 
      }

      file { "/tmp/miniconda.sh":
        ensure => present,
        mode   => 0755,
        require => Exec["download_installer"],
      }

      exec { "remove_installer":
        path    => "/usr/local/bin:/usr/bin:/bin",
        command => "rm -rf /tmp/miniconda.sh",
      }
    }

    pin: {
      exec { "touch ${path}/conda-meta/pinned":
        path    => "/usr/local/bin:/usr/bin:/bin",
        creates => inline_template("${path}/conda-meta/pinned"),
      }
    }

    config: {
      exec { "conda config $args":
        path    => "${path}/bin:/usr/local/bin:/usr/bin:/bin",
      }
    }

    update: {
      exec { "conda update $args":
        path    => "${path}/bin:/usr/local/bin:/usr/bin:/bin",
        timeout => 3600,
      }
    }

    install: {
      exec { "conda install $args":
        path    => "${path}/bin:/usr/local/bin:/usr/bin:/bin",
      }
    }

    clean: {
      exec { "conda clean --all":
        path    => "${path}/bin:/usr/local/bin:/usr/bin:/bin",
      }
    }
  }
}
