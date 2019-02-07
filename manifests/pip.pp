define hysds_base::pip($ensure = installed) {
  case $ensure {
    installed: {
      exec { "/opt/conda/bin/pip install $name":
        path => "/opt/conda/bin:/usr/local/bin:/usr/bin:/bin",
        unless => "/opt/conda/bin/pip show $name",
        timeout => 1800,
      }
    }
    latest: {
      exec { "/opt/conda/bin/pip install --upgrade $name":
        path => "/opt/conda/bin:/usr/local/bin:/usr/bin:/bin",
        timeout => 1800,
      }
    }
    default: {
      exec { "/opt/conda/bin/pip install $name==$ensure":
        path => "/opt/conda/bin:/usr/local/bin:/usr/bin:/bin",
        timeout => 1800,
      }
    }
  }
}
