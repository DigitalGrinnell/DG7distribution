# This is the init.pp manifest for the Puppet "dynmotd" module.  The original concept for dynmotd is found at
# http://parkersamp.com/2010/10/howto-creating-a-dynamic-motd-in-linux/

class dynmotd( ) {

# Make sure 'figlet' is installed because the dynmotd script uses it.
  package { 'figlet':
    ensure => installed,
  }

# Drop the dynmotd.sh script into /usr/local/bin as 'dynmotd' and make it executable
  file { '/usr/local/bin/dynmotd' :
    ensure => present,
	  content => template( 'dynmotd/dynmotd.sh' ),
	  require => [ Package[ 'figlet' ], File[ '/etc/motd-maint' ]],
    owner => 0, group => 0, mode => 755,
  }

## Append a command to the default user login ( /etc/profile ) by dropping the dynmotd_commands.sh script
# into /etc/profile.d/dynmotd_commands.sh.  Make it executable.
#  file { '/etc/profile.d/dynmotd_commands.sh' :
#    ensure => present,
#    content => template( 'dynmotd/dynmotd_commands.sh' ),
#	  owner => 0, group => 0, mode => 755,
#  }
## Above block replaced by...

## Append a dynmotd command to the vagrant user's ~/.profile
file_line { 'append-to-vagrant-profile' :
  path  => '/home/vagrant/.profile',
  line  => '/usr/local/bin/dynmotd',
  match => '/usr/local/bin/dynmotd',
  require => File['/usr/local/bin/dynmotd'],
 }


# Create a symlink called 'motd' in /usr/local/bin to effectively create a new command.
  file { '/usr/local/bin/motd':
     ensure => link,
     target => '/usr/local/bin/dynmotd',
  }

}
