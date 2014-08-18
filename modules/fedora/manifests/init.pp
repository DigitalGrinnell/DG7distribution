## This is the init.pp manifest for the Puppet "fedora" module, designed to install
## a Fedora Commons repository on the target server.  This manifest
## adapted by Mark McFate from https://wiki.duraspace.org/display/ISLANDORA713/Installing+Fedora

class fedora {

  ## Define some Fedora environment variables...these should match the contents of the 'environment' file!
  $FEDORA_USER_HOME = '/home/fedora'
  $FEDORA_USER = 'fedora'

  $fedora_environment = [ 'FEDORA_HOME=/usr/local/fedora',
                          'FEDORA_USER=fedora',
                          'CATALINA_HOME=/usr/local/fedora/tomcat',
                          "JAVA_OPTS='-Xms1024m -Xmx1024m -XX:MaxPermSize=512m -Djavax.net.ssl.trustStore=/usr/local/fedora/server/truststore -Djavax.net.ssl.trustStorePassword=tomcat'",
                          'JAVA_HOME=/usr/lib/jvm/java-7-oracle',
                          'JRE_HOME=/usr/lib/jvm/java-7-oracle/jre',
                          'KAKADU_LIBRARY_PATH=/opt/adore-djatoka-1.1/lib/Linux-x86-64', ]

  ## Create the 'fedora' user with a blank password and no login shell to securely own and run the service.
  $user = "${FEDORA_USER}"
  group { "${user}" :
    ensure => present,
  }

  ## The following configuration, for production, provides a user with no login shell and no password,
  ## so nobody can login and authenticate as this user.
#  exec { 'add-fedora-user' :
#    command => "useradd -m -g ${FEDORA_USER} -d ${FEDORA_USER_HOME} -s /bin/false ${FEDORA_USER}; usermod --shell /bin/false ${FEDORA_USER}",
#    require => Group["${user}"],
#    before => [ File['/etc/init.d/tomcat'], Exec["mysql-user-create-fedora"], Exec["install-fedora"], File["/usr/local/fedora"], ],
#  }

  ## Alternatively, to create a user for development use this configuration.
  user { fedora :
    ensure     => present,
    gid        => 'fedora',
    shell      => '/bin/bash',
    password   => "${master_password}",
    managehome => true,
    require    => Group['fedora'],
    before => [ File['/etc/init.d/tomcat'], Exec["mysql-user-create-fedora"], Exec["install-fedora"], File["/usr/local/fedora"], ],
  }

  ## Create the fedoraAdmin user and group.
  group { fedoraAdmin :
    ensure => present,
  }
  user { fedoraAdmin :
    ensure     => present,
    gid        => 'fedoraAdmin',
    shell      => '/bin/bash',
    password   => "${master_password}",
    managehome => true,
    require    => Group[ 'fedoraAdmin' ]
  }

  ## Append a dynmotd command to the fedoraAdmin user's ~/.profile
  file_line { 'append-to-fedoraAdmin-profile' :
    path  => '/home/fedoraAdmin/.profile',
    line  => '/usr/local/bin/dynmotd',
    match => '/usr/local/bin/dynmotd',
    require => File['/usr/local/bin/dynmotd'],
   }

  ## Populate /etc/environment to give variables global scope and /etc/profile.d/fedora.sh
  ## to comply with the Fedora/Tomcat startup script at /etc/init.d/tomcat.
  file { "/etc/environment" :
    ensure => present,
    source => "puppet:///modules/fedora/environment",
  }

  file { "/etc/profile.d/fedora.sh" :
    ensure => present,
    source => "puppet:///modules/fedora/environment",
  }

  ## Automate the tomcat server per http://askubuntu.com/questions/223944/how-to-automatically-restart-tomcat7-on-system-reboots.
  file { '/etc/init.d/tomcat' :
    ensure => present,
    source => "puppet:///modules/fedora/fedora-init-script",
    owner => 'fedora',
    group => 'fedora',
    mode => 755,
  }

  exec { 'tomcat-update-rc.d' :
    command => 'update-rc.d tomcat defaults',
    require => File['/etc/init.d/tomcat'],
  }

  ## Create a default MySQL database.
  exec { "mysql-db-create-${database}" :
    command => "mysql -uroot -p${mysql_root_password} -e \"CREATE DATABASE IF NOT EXISTS ${database}\"",
    require => Exec[ 'set-mysql-password' ],
  }

  ## Create a MySQL user and add it to the target database.
  $mysql_user = $user
  exec { "mysql-user-create-${mysql_user}" :
      command => "mysql -uroot -p${mysql_root_password} -e \"GRANT ALL PRIVILEGES ON *.* TO '${mysql_user}'@'localhost' IDENTIFIED BY '${master_password}'; FLUSH PRIVILEGES;\"",
      require => [
        Exec[ 'set-mysql-password' ],
        Exec[ "mysql-db-create-${database}" ],
      ],
    }

  ## Prep for Fedora install.
  file { "/tmp/install.properties" :
    ensure => present,
    content => template("fedora/install.properties.erb"), }
  file { "/tmp/fcrepo-installer.jar" :
    ensure => present,
    source => 'puppet:///modules/fedora/fcrepo-installer-3.7.1.jar', }

  ## Install Fedora
  exec { "install-fedora" :
    command => "java -jar fcrepo-installer.jar install.properties",
    path => ["/bin", "/usr/bin", "/usr/sbin", "/usr/bin/java",],
    cwd => '/tmp',
    require => [ File["/tmp/install.properties"],
                 File["/tmp/fcrepo-installer.jar"],
                 Package['oracle-java7-installer'], ],
    environment => $fedora_environment,
    creates => '/usr/local/fedora/install',
  }

  file { "/usr/local/fedora/tomcat/conf/tomcat-users.xml" :
    ensure => present,
    content => template("fedora/tomcat-users.xml.erb"),
    require => Exec['install-fedora'],
  }

  ## Apply a necessary database fix per the last section of http://v2p2dev.to.cnr.it/doku.php?id=repo371:base
  file { '/usr/local/fedora/tomcat/temp' :
    ensure => directory, owner => 'fedora', group => 'fedora', require => File['/usr/local/fedora/tomcat'], }
  file { '/usr/local/fedora/tomcat/temp/fedora-fix.sql' :
    ensure => present,
    source => 'puppet:///modules/fedora/fedora-fix.sql',
    require => Exec['start-fedora'], # require => Exec['unzip-fedora'],
  }
  exec { 'fix-fedora-database' :
    cwd => '/usr/local/fedora/tomcat/temp',
    command => "mysql -u${user} -p${mysqlpw} '${database}' < '/usr/local/fedora/tomcat/temp/fedora-fix.sql'",
    require => [ File['/usr/local/fedora/tomcat/temp/fedora-fix.sql'], Exec['start-fedora'], ],
  }

## Doesn't work and probably not worth having for our application!
#  ## Apply a fix to eliminate the message which reads:
#  ##  INFO: The APR based Apache Tomcat Native library which allows optimal performance...
#  ##  See http://tomcat.apache.org/native-doc/ for details.
#  $apr_packages = [ "libapr1-dev", "libssl-dev", ]
#  package { $apr_packages:
#    ensure => present,
#    require => Exec["apt-get update"]
#  }
#  file { "/opt/adore-djatoka-1.1/lib/Linux-x86-64/libapr-1.so":
#    ensure => link,
#    target => "/usr/lib/x86_64-linux-gnu/libapr-1.so",
#    require => Package['libapr1-dev'],
#  }
#  file { "/opt/adore-djatoka-1.1/lib/Linux-x86-64/libssl.so":
#    ensure => link,
#    target => "/usr/lib/x86_64-linux-gnu/libssl.so",
#    require => Package['libssl-dev'],
#  }
## Doesn't work and probably not worth having for our application!

  file { '/usr/local/fedora/tomcat' :
    ensure => directory, owner => 'fedora', group => 'fedora', require => Exec['start-fedora'], }
  file { '/usr/local/fedora/tomcat/bin' :
    ensure => directory, owner => 'fedora', group => 'fedora', }
  file { '/usr/local/fedora/tomcat/bin/setenv.sh' :
    ensure => present,
    source => 'puppet:///modules/fedora/setenv.sh',
    require => Exec['start-fedora'],
  }

  ## Set XACML policies per https://wiki.duraspace.org/display/ISLANDORA713/Installing+Fedora
  file { "/usr/local/fedora" :
    ensure => 'directory', owner => 'fedora', group => 'fedora',
    require => Exec['start-fedora'], }
  file { "/usr/local/fedora/data" :
    ensure => 'directory', owner => 'fedora', group => 'fedora',
    require => File['/usr/local/fedora'], }
  file { "/usr/local/fedora/data/fedora-xacml-policies" :
    ensure => 'directory', owner => 'fedora', group => 'fedora',
    require => File['/usr/local/fedora/data'], }
  file { "/usr/local/fedora/data/fedora-xacml-policies/repository-policies" :
    ensure => 'directory', owner => 'fedora', group => 'fedora',
    require => File['/usr/local/fedora/data/fedora-xacml-policies'], }
  file { "/usr/local/fedora/data/fedora-xacml-policies/repository-policies/default" :
    ensure => 'directory', owner => 'fedora', group => 'fedora',
    require => File['/usr/local/fedora/data/fedora-xacml-policies/repository-policies'], }
  file { "/usr/local/fedora/data/fedora-xacml-policies/repository-policies/islandora" :
    ensure => 'directory', owner => 'fedora', group => 'fedora',
    require => File['/usr/local/fedora/data/fedora-xacml-policies/repository-policies'], }

  vcsrepo { "/usr/local/fedora/data/fedora-xacml-policies/repository-policies/islandora" :
    ensure => present,
    provider => git,
    source => 'git://github.com/Islandora/islandora-xacml-policies.git',
    require => Exec['start-fedora'], # require => Exec['unzip-fedora'],
  }

  file { "/usr/local/fedora/data/fedora-xacml-policies/repository-policies/default/deny-purge-datastream-if-active-or-inactive.xml" :
    ensure => absent, require => Exec['start-fedora'], }
  file { "/usr/local/fedora/data/fedora-xacml-policies/repository-policies/default/deny-purge-object-if-active-or-inactive.xml" :
    ensure => absent, require => Exec['start-fedora'], }
  # Removing these next two per Gervais' recommendation on July 17, 2014
  file { "/usr/local/fedora/data/fedora-xacml-policies/repository-policies/default/deny-inactive-or-deleted-objects-or-datastreams-if-not-administrator.xml" :
    ensure => absent, require => Exec['start-fedora'], }
  file { "/usr/local/fedora/data/fedora-xacml-policies/repository-policies/default/deny-policy-management-if-not-administrator.xml" :
    ensure => absent, require => Exec['start-fedora'], }
  # Modifying the next policy per Gervais' critical instruction on July 17, 2014!
  file { '/usr/local/fedora/data/fedora-xacml-policies/repository-policies/default/deny-apim-if-not-localhost.xml' :
    ensure => present, owner => 'fedora', group => 'fedora', mode => 664,
    source => 'puppet:///modules/fedora/deny-apim-if-not-localhost.xml',
    require => Exec['start-fedora'],
  }

  file { '/usr/local/fedora/server/config/jaas.conf' :
    ensure => present,
    source => "puppet:///modules/fedora/jaas.conf",
    owner => 'fedora', group => 'fedora',
    require => Exec['start-fedora'], # require => Exec['unzip-fedora'],
  }
  file { "/usr/local/fedora/server/config/filter-drupal.xml" :
    ensure => present,
    content => template("fedora/filter-drupal.xml.erb"),
    owner => 'fedora', group => 'fedora',
    require => Exec['start-fedora'], # require => Exec['unzip-fedora'],
  }

  ## Start fedora.  Afterward, sleep for 10 seconds to give the .jar's time to unpack!
  ## Note that this construct is intended for Puppet use and initial startup of Tomcat.
  exec { 'start-fedora' :
   cwd => '/usr/local/fedora',
   command => "chown fedora:fedora -R .; service tomcat start; sleep 10",
   path => ["/bin", "/usr/bin", "/usr/sbin", "/usr/bin/java",],
   require => [ Exec['install-fedora'], Exec['tomcat-update-rc.d'], ],
   environment => $fedora_environment,
  }

}
