define hysds_base::pip($ensure = installed, $wheel = "") {
  if $wheel != "" {
    $pkg = $wheel
  }
  else {
    $pkg = $name
  } 
  case $ensure {
    installed: {
      exec { "/opt/conda/bin/pip install $pkg":
        path => "/opt/conda/bin:/usr/local/bin:/usr/bin:/bin",
        unless => "/opt/conda/bin/pip show $name",
        timeout => 1800,
      }
    }
    latest: {
      exec { "/opt/conda/bin/pip install --upgrade $pkg":
        path => "/opt/conda/bin:/usr/local/bin:/usr/bin:/bin",
        timeout => 1800,
      }
    }
    default: {
      exec { "/opt/conda/bin/pip install $pkg==$ensure":
        path => "/opt/conda/bin:/usr/local/bin:/usr/bin:/bin",
        timeout => 1800,
      }
    }
  }
}
