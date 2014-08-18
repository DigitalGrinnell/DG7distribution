## This is the init.pp manifest for post-installation parts of the Puppet "fedora" module.
## This manifest adapted by Mark McFate from https://wiki.duraspace.org/display/ISLANDORA713/Installing+Fedora.
## Note that actions initiated here will break some portion of the Fedora/Tomcat installation
## if not deferred!

class fedora_post-install {

  File { #defaults
    require => [ Class['fedora'], Class['djatoka'], ],
    before => Exec['restart-fedora'],
  }

  ## Improve logging of Fedora errors per http://java.dzone.com/articles/tomcat-6-infamous-%E2%80%9Csevere
  ## Breaks Adore-Djatoka if moved too early!
  file { "/usr/local/fedora/tomcat/webapps/fedora/WEB-INF/classes/logging.properties" :
    ensure => present, owner => 'fedora', group => 'fedora',
    source => 'puppet:///modules/fedora_post-install/logging.properties',
  }

  ## Install the Drupal auth filter per https://wiki.duraspace.org/pages/viewpage.action?pageId=34638844
  ## and http://freedaleaskey.plggta.org/sites/default/files/fcrepo-drupalauthfilter-3.7.1.jar. 
  file { '/usr/local/fedora/tomcat/webapps/fedora/WEB-INF/lib/fcrepo-drupalauthfilter-3.7.1.jar' :
    ensure => present, owner => 'fedora', group => 'fedora', mode => 664,
    source => "puppet:///modules/fedora_post-install/fcrepo-drupalauthfilter-3.7.1.jar",
  }

  ## Apply more Fedora Commons configuration per http://asingh.com.np/blog/fedora-commons-installation-and-configuration-guide/
  ## and http://doauto.wordpress.com/2013/06/22/how-to-change-a-file-using-puppet/
  file_line { 'replace-admin-email' :
    path  => '/usr/local/fedora/tomcat/webapps/fedora/WEB-INF/applicationContext.xml',
    line  => "<property name=\"value\" value=\"${admin_email} example@example.org\" />",
    match => 'example\.org',
    require => [ Class['fedora'], Class['djatoka'], ],
    before => Exec['restart-fedora'],
  }

  ## Direct the adore-djatoka logs per https://wiki.duraspace.org/display/ISLANDORA112/Chapter+12+-+Installing+Solution+Pack+Dependencies
  file { '/usr/local/fedora/tomcat/webapps/adore-djatoka/WEB-INF/classes/log4j.properties' :
    ensure => present, owner => 'fedora', group => 'fedora',
    source => "puppet:///modules/djatoka/log4j.properties",
  }

  ## Restart fedora.  This is intended to be called before additional .jar's might be added.
  ## Note that this construct is intended for Puppet use and NOT initial startups of Tomcat.
  exec { 'restart-fedora' :
    command => "service tomcat restart; sleep 10",
    require => [ Class['fedora'], Class['djatoka'], ],
   }

}
