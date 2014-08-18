## manifests\!!!!02!!!!.pp
## This is the main manifest.

# @TODO... Move the parameters to an UNDISTRIBUTED manifest somewhere or Hiera!
# @TODO... http://garylarizza.com/blog/2014/02/17/puppet-workflow-part-1/

# Define some required parameters
$node = '!!!!02!!!!'                      ## Attention!
$my_hostname = "${node}.!!!!04!!!!"      ## Attention!
$master_password = '!!!!07!!!!'        ## Attention!
$database = '!!!!08!!!!'                      ## Attention!
$admin_email = 'digital@!!!!03!!!!'      ## Attention!
$pid_namespace = 'grinnell'                ## Attention!

$back_end_static_ip1 = '132.161.216.45'    ## Attention!
$back_end_static_ip2 = '192.168.1.100'     ## Attention!

## The following describe the 'front-end' (Islandora/Drupal) server, not this back-end!
## For purposes of configuring the Drupal auth filter, filter-drupal.xml.
$front_end_hostname = '!!!!01!!!!'
$front_end_database = '!!!!06!!!!'
$front_end_db_user = 'digital'
$front_end_db_password = '!!!!05!!!!'

# root mysql password
$mysql_root_password = $master_password
$mysqlpw = $mysql_root_password

## default path
Exec {
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}

## Drop the !!!!02!!!!_motd-maint.txt file into /etc/motd-maint
file { '/etc/motd-maint':
  ensure => present,
  source => 'puppet:///modules/dynmotd/!!!!02!!!!_motd-maint.txt',
  owner => 0, group => 0, mode => 666,
}

## Credit the following to http://puppetlabs.com/blog/lamp-stacks-made-easy-vagrant-puppet
## and https://github.com/jrodriguezjr/puppet-lamp-stack.git

include bootstrap
include tools
include mysql

## MAM additions follow
##

include network
include dynmotd
include timezone
include git
include stdlib
include apt
include java7
include fedora
include djatoka                # Needed for several image handling parts
include fedora_post-install

# MAM - Added along with Vagrantfile changes per https://github.com/mitchellh/vagrant/issues/743#issuecomment-16442405
exec{ 'set_back_end_static_IP' :
  command => "/sbin/ifconfig eth1 ${back_end_static_ip1} netmask 255.255.255.0 up;
              /sbin/ifconfig eth2 ${back_end_static_ip2} netmask 255.255.255.0 up ", }






