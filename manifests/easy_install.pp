define hysds_base::easy_install($ensure = installed) {
  case $ensure {
    installed: {
      exec { "/opt/conda/bin/easy_install $name":
        path    => "/opt/conda/bin:/usr/local/bin:/usr/bin:/bin",
        creates => inline_template("/usr/lib/python3.7/site-packages/<%= File.basename(@name) %>"),
        timeout => 1800,
      }
    }
    latest: {
      exec { "/opt/conda/bin/easy_install --upgrade $name":
        path    => "/opt/conda/bin:/usr/local/bin:/usr/bin:/bin",
        timeout => 1800,
      }
    }
  }
}
