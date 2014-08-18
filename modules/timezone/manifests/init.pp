# This is the init.pp manifest for the Puppet "timezone" module.

class timezone {

  ## Set server to US Central timezone.
  ## From http://pfigue.github.io/blog/2013/11/29/a-puppet-manifest-to-set-the-timezone/

  file { '/etc/timezone':
    ensure => present,
    content => "America/Chicago\n",
  }

  exec { 'reconfigure-tzdata':
    user => root,
    group => root,
    command => '/usr/sbin/dpkg-reconfigure --frontend noninteractive tzdata',
  }

  notify { 'timezone-changed':
    message => 'Timezone was updated to US Central (America/Chicago)',
  }

  File['/etc/timezone'] -> Exec['reconfigure-tzdata'] -> Notify['timezone-changed']

}
