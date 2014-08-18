## This is the init.pp manifest for the Puppet "djatoka" module.  This manifest
## adapted by Mark McFate from a webmin script originally forked
## from http://projects.puppetlabs.com/projects/1/wiki/Webmin_Patterns
## Final 'Cleanup_Djatoka' bits of this from http://v2p2dev.to.cnr.it/doku.php?id=isla2:tools.

class djatoka {

  $base = "adore-djatoka-1.1"
  $tar = "${base}.tar"
  $gz = "${tar}.gz"
  $url = "http://sourceforge.net/projects/djatoka/files/djatoka/1.1/"
  $archive = "/root/${gz}"
  $target = "/opt"
  $installed = "/${target}/${base}"

  exec { 'download-djatoka' :
      cwd => "/root",
      command => "wget '${url}${gz}'",
      creates => "${archive}",
  }

  exec { "install-djatoka" :
      cwd => "/root",
      command => "/bin/gunzip ${archive}; /bin/tar -xvf ${tar}; mv -f ${base} ${target}/",
      creates => "${installed}",
      require => Exec[ "download-djatoka" ],
  }

  exec { "copy-djatoka-war" :
      cwd => "${installed}/dist",
      command => "cp ./adore-djatoka.war /usr/local/fedora/tomcat/webapps",
      creates => "/usr/local/fedora/tomcat/webapps/${base}.war",
      require => Exec[ "install-djatoka" ],
  }

  exec { "cleanup-djatoka" :
      cwd => "/root",
      command => "cp ${installed}/bin/Linux-x86-64/* /usr/local/bin/; cp ${installed}/lib/Linux-x86-64/* /usr/local/lib/; rm -f ${base}*;  ldconfig",
      require => Exec[ "install-djatoka" ],
  }

  ## Add startup parameters per https://wiki.duraspace.org/display/ISLANDORA112/Chapter+12+-+Installing+Solution+Pack+Dependencies
  file { '/usr/local/fedora/tomcat/bin/startup.sh' :
    ensure => present,
    source => "puppet:///modules/fedora/startup.sh",
    require => Exec['cleanup-djatoka'],
  }

  ## Make env changes per https://wiki.duraspace.org/display/ISLANDORA112/Chapter+12+-+Installing+Solution+Pack+Dependencies
  file { '/opt/adore-djatoka-1.1/bin/env.sh' :
    ensure => present,
    source => "puppet:///modules/fedora/env.sh",
    require => Exec['cleanup-djatoka'],
  }

#  ## Unzip Adore-Djatoka
#  exec { "unzip-djatoka" :
#    command => "chown fedora:fedora -R .; jar xvf adore-djatoka.war; chown fedora:fedora -R .",
#    path => ["/bin", "/usr/bin", "/usr/sbin", "/usr/bin/java",],
#    cwd => '/usr/local/fedora/tomcat/webapps',
#    require => Exec['copy-djatoka-war'],
#    creates => '/usr/local/fedora/tomcat/webapps/adore-djatoka',
#  }

}

