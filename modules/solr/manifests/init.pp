# Install and configure SOLR and FedoraGSearch
# As root...!
# Following install of SOLR 4.2 (but for SoLR 4.2.1) at https://github.com/discoverygarden/basic-solr-config/wiki/Guide-to-Setting-up-GSearch-2.7-with-Solr-4.2.0.

class { solr :

  # SOLR 4.2.1 install

  service { tomcat :
    ensure => stopped,
    before => File['/opt/solr-4.2.1.tgz'],
  }
  file{ '/opt/solr-4.2.1.tgz' :
    ensure => present,
    source => 'puppet:///modules/solr/solr-4.2.1.tgz',
    before => Exec['untar-solr'],
  }
  exec{ 'untar-solr' :
    cwd => '/opt',
    command => 'tar -xvzf solr-4.2.1.tgz',
    creates => '/opt/solr-4.2.1',
    before => File['/opt/solr'],
  }
  file{ '/opt/solr' :
    ensure => link,
    target => '/opt/solr-4.2.1',
    before => File['/usr/local/fedora/tomcat/conf/Catalina/localhost/solr.xml'],
  }
  file{ '/usr/local/fedora/tomcat/conf/Catalina/localhost/solr.xml' :
    ensure => present,
    source => 'puppet:///modules/solr/solr.xml',
    before => File['/usr/local/fedora/solr'],
  }
  file{ '/usr/local/fedora/solr' :
    ensure => directory,
    before => Exec['copy-solr-from-opt'],
    owner => 'fedora',
    group => 'fedora',
  }
  exec { 'copy-solr-from-opt' :
    cwd => '/opt/solr/example/solr/collection1',
    command => 'cp -fr * /usr/local/fedora/solr/collection1',
    creates => '/usr/local/fedora/solr/collection1/conf',
    before => File['/usr/local/fedora/tomcat/webapps/fedoragsearch/FgsConfig/fgsconfig-basic.properties'],
    user => 'fedora',
  }
  file { '/usr/local/fedora/tomcat/webapps/fedoragsearch/FgsConfig/fgsconfig-basic.properties' :
    ensure => present,
    source => 'puppet:///modules/solr/fgsconfig-basic.properties',
    before => File['/usr/local/fedora/solr/collection1/conf/schema.xml'],
    owner => 'fedora', group => 'fedora',
  }
  file { '/usr/local/fedora/solr/collection1/conf/schema.xml' :
    ensure => present,
    source => 'puppet:///modules/solr/schema.xml',
    before => File['/usr/local/fedora/solr/collection1/conf/solrconfig.xml'],
    owner => 'fedora', group => 'fedora',
  }
  file { '/usr/local/fedora/solr/collection1/conf/solrconfig.xml' :
    ensure => present,
    source => 'puppet:///modules/solr/solrconfig.xml',
    before => Exec['restart_tomcat_for_solr'],
    owner => 'fedora', group => 'fedora',
  }
  exec { 'restart_tomcat_for_solr' :
    cwd => '/tmp',
    user => 'root',
    command => 'service tomcat restart',
    before => File['/usr/local/fedora/tomcat/webapps/fedoragsearch-2.7.zip'],
  }

  # Note: At this point the SOLR index directory, /usr/local/fedora/solr/collection1/data/index does NOT exist.
  # SOLR documentation says this is OK, SOLR will create it automatically.  We shall see.

  # Now for GSearch 2.7.

  file { '/usr/local/fedora/tomcat/webapps/fedoragsearch-2.7.zip' :
    ensure => present,
    source => 'puppet:///modules/solr/fedoragsearch-2.7.zip',
    before => Exec['unzip-gsearch'],
    owner => 'fedora', group => 'fedora',
  }
  exec{ 'unzip_gsearch' :
    cwd => '/usr/local/fedora/tomcat/webapps',
    command => 'unzip fedoragsearch-2.7.zip',
    creates => '/usr/local/fedora/tomcat/webapps/fedoragsearch-2.7',
    before => Exec['move_gsearch_war'],
    requires => Package[ 'unzip' ],
  }
  exec{ 'move_gsearch_war' :
    cwd => '/usr/local/fedora/tomcat/webapps',
    command => 'mv -f fedoragsearch-2.7/fedoragsearch.war .; pause 10',
    creates => '/usr/local/fedora/tomcat/webapps/fedoragsearch.war',
    before => File['/usr/local/fedora/tomcat/webapps/fedoragsearch-2.7'],
    user => 'fedora',
  }
  file { '/usr/local/fedora/tomcat/webapps/fedoragsearch-2.7' :
    ensure => absent,
    before => File['/usr/local/fedora/tomcat/webapps/fedoragsearch/FgsConfig/fgsconfig-basic.properties'],
  }
  file{ '/usr/local/fedora/tomcat/webapps/fedoragsearch/FgsConfig/fgsconfig-basic.properties' :
    ensure => present,
    source => 'puppet:///modules/solr/fgsconfig-basic.properties',
    before => Exec['ant_two_files'],
    owner => 'fedora', group => 'fedora',
  }
  Exec { 'ant_two_files' :
    cwd => '/usr/local/fedora/tomcat/webapps/fedoragsearch/FgsConfig' :
    command => 'ant generateIndexingXslt; ant -f fgsconfig-basic.xml',
    user => 'fedora',
    before => File['/usr/local/fedora/tomcat/webapps/fedoragsearch/WEB-INF/classes/fgsconfigFinal/index/FgsIndex/foxmlToSolr.xslt'],
  }
  file { '/usr/local/fedora/tomcat/webapps/fedoragsearch/WEB-INF/classes/fgsconfigFinal/index/FgsIndex/foxmlToSolr.xslt' :
    ensure => present,
    source => 'puppet:///modules/solr/FgsIndex/foxmlToSolr.xslt',
    before => File['/usr/local/fedora/tomcat/webapps/fedoragsearch/WEB-INF/classes/fgsconfigFinal/index/FgsIndex/islandora_transforms' :
  }
  file { '/usr/local/fedora/tomcat/webapps/fedoragsearch/WEB-INF/classes/fgsconfigFinal/index/FgsIndex/islandora_transforms' :
    ensure => directory,
    source => 'puppet:///modules/solr/FgsIndex/islandora_transforms',
    owner => 'fedora', group => 'fedora',
    recurse => true,
    before => File['/usr/local/fedora/tomcat/webapps/fedoragsearch/WEB-INF/classes/fgsconfigFinal/index/FgsIndex/islandora_transforms' :
  }



nano index.properties   ## uncomment the 'fgsindex.uriResolver    =' at the end of the file
service tomcat restart
# OK, but when doing updateIndex I get this again...
# Fri Jul 25 23:39:55 CDT 2014 IndexReader open error indexName=FgsIndex : ; nested exception is: org.apache.lucene.store.NoSuchDirectoryException: directory '/usr/local/fedora/solr/collection1/data/index' does not exist













