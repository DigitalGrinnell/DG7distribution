class tools {

  # package install list
  $packages = [
    "curl",
    "vim",
    "htop",
    "nano",         # MAM added 25-Apr-2014
    "unzip",        # MAM added 27-Jul-2014
    "ant",          # MAM added 27-Jul-2014
    "maven",        # MAM added 28-Jul-2014
    "sendmail",     # MAM added 13-Aug-2014
  ]

  # install packages
  package { $packages:
    ensure => present,
    require => Exec["apt-get update"]
  }
}
