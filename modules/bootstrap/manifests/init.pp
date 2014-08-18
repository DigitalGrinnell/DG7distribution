class bootstrap {

  # silence puppet and vagrant annoyance about the puppet group
  group { 'puppet' :
    ensure => 'present'
  }

  # ensure local apt cache index is up to date before beginning
  exec { 'apt-get update' :
    command => '/usr/bin/apt-get update'
  }

  # MAM - The following added to satisfy missing reference for 'drush'.
  exec { 'update_apt' :
    command => '/usr/bin/apt-get update'
  }

}
