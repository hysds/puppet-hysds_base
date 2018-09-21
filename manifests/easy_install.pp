define hysds_base::easy_install($ensure = installed) {
  case $ensure {
    installed: {
      exec { "/usr/bin/easy_install $name":
        path    => "/usr/local/bin:/usr/bin:/bin",
        creates => inline_template("/usr/lib/python2.7/site-packages/<%= File.basename(@name) %>"),
        timeout => 1800,
      }
    }
    latest: {
      exec { "/usr/bin/easy_install --upgrade $name":
        path    => "/usr/local/bin:/usr/bin:/bin",
        timeout => 1800,
      }
    }
  }
}
