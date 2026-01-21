define hysds_base::conda($path='/opt/conda', $action=install_miniforge, $args='') {
  case $action {
    install_miniforge: {
      exec { "install_conda":
        path    => "/usr/local/bin:/usr/bin:/bin",
        command => "/tmp/miniforge.sh -b -p $path",
        creates => $path,
        require => File["/tmp/miniforge.sh"],
        notify  => Exec["remove_installer"],
      }

      exec { "download_installer":
        path    => "/usr/local/bin:/usr/bin:/bin",
        command => "ARCH=$(uname -m) && curl -sSL https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-${ARCH}.sh -o /tmp/miniforge.sh",
        creates => "/tmp/miniforge.sh",
      }

      file { "/tmp/miniforge.sh":
        ensure => present,
        mode   => "0755",
        require => Exec["download_installer"],
      }

      exec { "remove_installer":
        path    => "/usr/local/bin:/usr/bin:/bin",
        command => "rm -rf /tmp/miniforge.sh",
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
