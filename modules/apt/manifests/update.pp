## MAM Note
## If a NO_PUBKEY error pops up try this in front of apt-get update...
##   apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3E5C1192
## Per http://www.webupd8.org/2010/10/fix-nopubkey-error-for-extras-ubuntu.html
#
class apt::update {
  include apt::params

  exec { 'apt-key-fix' :
    command => 'apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3E5C1192',
    logoutput   => 'on_failure',
    refreshonly => true,
    timeout     => $apt::update_timeout,
    tries       => $apt::update_tries,
    try_sleep   => 1,
    before      => Exec['apt_update'],
  }

  exec { 'apt_update':
    command     => "${apt::params::provider} update",
#   command     => "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3E5C1192; ${apt::params::provider} update",
#   command     => "echo 'apt_update has been temporarily disabled in apt/manifests/update.pp'",
    logoutput   => 'on_failure',
    refreshonly => true,
    timeout     => $apt::update_timeout,
    tries       => $apt::update_tries,
    try_sleep   => 1
  }
}
