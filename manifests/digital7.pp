## manifests\!!!!01!!!!.pp
## This is the main manifest.

## Define some required parameters
$node = '!!!!01!!!!'                         ## Attention!
$user = 'digital'                          ## Attention!
$webroot = '/var/www'                      ## Attention!
$drupal_core = '7.27'                      ## Attention!
$master_password = '!!!!05!!!!'              ## Attention!
$database = '!!!!06!!!!'              ## Attention!

$front_end_static_ip1 = '132.161.216.46'   ## Attention!
$front_end_static_ip2 = '192.168.1.101'    ## Attention!

# root mysql password
$mysql_root_password = $master_password    ## Attention!
$mysqlpw = $mysql_root_password

# MAM - Added along with Vagrantfile changes per https://github.com/mitchellh/vagrant/issues/743#issuecomment-16442405
exec{ 'set_front_end_static_IP' :
  command => "/sbin/ifconfig eth1 ${front_end_static_ip1} netmask 255.255.255.0 up;
              /sbin/ifconfig eth2 ${front_end_static_ip2} netmask 255.255.255.0 up ", }

## The list of Drupal contrib modules to download.  Note that the space following
## each module name is Important!
$drupal_modules = [                        ## Attention!
  'addanother ',
  'backup_migrate ',
  'date ',
  'devel ',
  'email ',
  'entity ',
  'fpa ',
  'globalredirect ',
  'login_destination ',
  'module_filter ',
  'page_title ',
  'pathauto ',
  'r4032login ',
  'remove_generator ',
  'transliteration ',
  'token_filter ',
  'masquerade ',
  'wysiwyg ',
  'context ',
  'phpmailer ',
  'maillog ',
  'ckeditor ',                   # MAM added 14-Aug-2014
  'views_bulk_operations ',      # MAM added 15-Aug-2014
]

## The following addtional Drupal modules for Islandora 7 from
## https://github.com/ryersonlibrary/islandora/blob/master/attributes/default.rb
$drupal_modules_islandora7 = [
  'libraries ',
  'advanced_help ',
  'imagemagick ',
  'ctools ',
  'token ',
  'views ',
  'jquery_update-7.x-2.x ',  # use latest dev version for compatibility with JQuery 1.10
  'relation ',               # NB dependency for islandora_sync
  'field_collection ',       # NB dependency for islandora_sync
  'views_ui ',
  'xmlsitemap ',             # NB dependency for islandora_xmlsitemap
]

$drupal_path = "${webroot}/drupal7"         ## Attention!
$drupal_contrib = "${drupal_path}/sites/all/modules/contrib"
$drupal_dirs = [
  "${drupal_path}",
  "${drupal_path}/sites",
  "${drupal_path}/sites/default",
  "${drupal_path}/sites/all",
  "${drupal_path}/sites/all/modules",
  "${drupal_path}/sites/all/modules/contrib",
  "${drupal_path}/sites/all/modules/custom",
  "${drupal_path}/sites/all/themes",
  "${drupal_path}/sites/all/libraries",
]

## default path
Exec {
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}

# Drop the !!!!01!!!!_motd-maint.txt file into /etc/motd-maint
file { '/etc/motd-maint':
  ensure => present,
  source => 'puppet:///modules/dynmotd/!!!!01!!!!_motd-maint.txt',
  owner => 0, group => 0, mode => 666,
}

## Credit the following to http://puppetlabs.com/blog/lamp-stacks-made-easy-vagrant-puppet
## and https://github.com/jrodriguezjr/puppet-lamp-stack.git

include bootstrap
include tools
include apache
include php
include php::pear
include php::pecl
include mysql

## MAM additions follow
##

include network
include dynmotd
include timezone
include webmin
include git
include stdlib
include apt
include java
include openseadragon
include image_handling

## Bring in Digital Grinnell specific stuff.
include !!!!01!!!!-grinnell

## Create a $user user and group.
group { $user :
        ensure => present,
}
user { $user :
       ensure     => present,
       gid        => $user,
       shell      => '/bin/bash',
       managehome => true,
       password   => "${master_password}",
       require    => Group[ $user ]
}

## Set default file owner, group and mode.
File {
  owner => $user,
  group => www-data,
  mode  => 644,
}

## Make sure we have our webroot after Apache2 is started.
file { $webroot :
  ensure => directory,
  mode => 755,
  require => Service[ apache2 ],
}

## Make sure we have a "private" files folder outside the webroot.
file { "${webroot}/../private" :
  ensure => directory,
  mode => 764,
  require => Service[ apache2 ],
}

## Roll in Drupal's core (if it's not already done, hence I added
## a 'creates' attribute in the drupal::core procedure.)
# include drush  ## MAM - Already included within Drupal.  Don't double up!
include drupal
drupal::core { $drupal_core :
  path => $drupal_path,
  require => Class[ drush ],     ## MAM addition to enforce dependency
  creates => "${drupal_path}/LICENSE.txt",     # MAM added 29-May-2014
}

## Ensure key Drupal directories exist...but only AFTER Drupal core is installed, otherwise
## it might be overlooked!
file { $drupal_dirs :
  ensure => directory,
  mode   => 744,
  require => Drupal::Core [ $drupal_core  ],
}

## Now roll in some "necessary" contibuted Drupal modules.
## This list largely adopted from http://www.ross.ws/content/drupal-7-essential-modules.
Drush::Exec {
  root_directory => $drupal_path,
}
drush::exec { drush-download-modules :
  command => "pm-download ${drupal_modules} --destination=${drupal_contrib}",
  require => [
    File[ "${drupal_contrib}" ],
    Drush::Exec [ "drush-drupal-core-download-${drupal_path}" ],
  ],
}
## And the following list adopted from https://github.com/ryersonlibrary/islandora/blob/master/attributes/default.rb
drush::exec { drush-download-modules-islandora :
  command => "pm-download ${drupal_modules_islandora7} --destination=${drupal_contrib}",
  require => [
    File[ "${drupal_contrib}" ],
    Drush::Exec [ "drush-drupal-core-download-${drupal_path}" ],
  ],
}

## Note: To enable the "necessary" modules use this from the command line...
#   drush en --yes addanother admin_menu* backup_migrate ctools date
#     date_all_day date_popup date_repeat date_repeat_field date_tools
#     date_views devel email entity entity_token fpa globalredirect
#     login_destination module_filter page_title pathauto r4032login
#     remove_generator token transliteration views views_ui xmlsitemap
#     xmlsitemap_engines xmlsitemap_menu xmlsitemap_node

## Set file ownership on ${drupal_path} and everything below it.
exec { set-drupal-file-permissions :
  command => "chown -R ${user}:www-data ${drupal_path}/*",
  require => [ Drush::Exec[ drush-download-modules ],
               Drush::Exec[ drush-download-modules-islandora ], ]
}

## Roll in xdebug
include xdebug
xdebug::config { 'default' :
  remote_enable => '1',
# remote_host => '132.161.216.181',   # No longer needed since remote_connect_back=1
  remote_port => '9000',              # Change default settings
}

## Roll in awstats
include awstats
awstats::awstats_vhost { "$fqdn" :
  ensure => present,
  docroot => '/var/www/',
  outputdir => '/var/www/awstats',
  user => 'www-data',
  group => 'www-data',
  domain => "${domain}",
  aliases => "${fqdn}",
  require  => Service[ apache2 ],  # MAM added
}

## Roll in Islandora dependencies from the pre-installation software checklist
## at https://wiki.duraspace.org/display/ISLANDORA713/Installing+the+Islandora+Module

Vcsrepo {                # defaults
  ensure => present,
  provider => git,
}
vcsrepo { "${drupal_path}/sites/all/libraries/tuque" :    # tuque library
  source => 'git://github.com/Islandora/tuque.git', }

## Roll in Islandora modules from Github per
## https://github.com/ryersonlibrary/islandora/blob/master/attributes/default.rb

# core modules
vcsrepo { "${drupal_path}/sites/all/modules/contrib/php_lib" :
  source => "git://github.com/Islandora/php_lib.git", }
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora" :
  source => "git://github.com/Islandora/islandora.git", }
vcsrepo { "${drupal_path}/sites/all/modules/contrib/objective_forms" :
  source => "git://github.com/Islandora/objective_forms.git", }

# solr indexing
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_solr_search" :
  source => "git://github.com/Islandora/islandora_solr_search.git", }
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_solr_metadata" :
  source => "git://github.com/Islandora/islandora_solr_metadata.git", }
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_solr_facet_pages" :
  source => "git://github.com/Islandora/islandora_solr_facet_pages.git", }

# solution packs
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_solution_pack_compound" :
  source => "git://github.com/Islandora/islandora_solution_pack_compound.git", }
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_solution_pack_pdf" :
  source => "git://github.com/Islandora/islandora_solution_pack_pdf.git", }
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_solution_pack_book" :
  source => "git://github.com/Islandora/islandora_solution_pack_book.git", }
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_solution_pack_video" :
  source => "git://github.com/Islandora/islandora_solution_pack_video.git", }
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_solution_pack_audio" :
  source => "git://github.com/Islandora/islandora_solution_pack_audio.git", }
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_solution_pack_image" :
  source => "git://github.com/Islandora/islandora_solution_pack_image.git", }
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_solution_pack_large_image" :
  source => "git://github.com/Islandora/islandora_solution_pack_large_image.git", }
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_solution_pack_web_archive" :
  source => "git://github.com/Islandora/islandora_solution_pack_web_archive.git", }
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_solution_pack_collection" :
  source => "git://github.com/Islandora/islandora_solution_pack_collection.git", }

# more goodies
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_scholar" :
  source => "git://github.com/Islandora/islandora_scholar.git", }
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_paged_content" :
  source => "git://github.com/Islandora/islandora_paged_content.git", }
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_bookmark" :
  source => "git://github.com/Islandora/islandora_bookmark.git", }
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_xml_forms" :
  source => "git://github.com/Islandora/islandora_xml_forms.git", }
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_xacml_editor" :
  source => "git://github.com/Islandora/islandora_xacml_editor.git", }
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_pdfjs_reader" :
  source => "git://github.com/nhart/islandora_pdfjs_reader.git", }

# phpMailer library
vcsrepo { "/var/www/drupal7/sites/all/libraries/phpmailer" :
  source => "git://github.com/PHPMailer/PHPMailer.git", }
# Make sure the main file, class.phpmailer.php, is located at
#   sites/all/libraries/phpmailer/class.phpmailer.php.


# pdf.js
vcsrepo { "${drupal_path}/sites/all/libraries/pdfjs" :
  source => "git://github.com/mozilla/pdf.js.git", }

# NicEdit
vcsrepo { "${drupal_path}/sites/all/libraries/nicedit" :
  source => "git://github.com/danishkhan/NicEdit.git", }

# CKEditor
vcsrepo { "${drupal_path}/sites/all/libraries/ckeditor" :
  source => "git://github.com/ckeditor/ckeditor-releases.git", }

# Islandora + Internet Archive Book Reader
vcsrepo { "${drupal_path}/sites/all/libraries/bookreader" :
  source => "git://github.com/Islandora/internet_archive_bookreader.git", }
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_internet_archive_bookreader" :
  source => "git://github.com/Islandora/islandora_internet_archive_bookreader.git", }

# Islandora OCR
vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_ocr" :
  source => "git://github.com/Islandora/islandora_ocr.git", }

# Install 'Lame' for MP3 playback.
package { 'lame' :
  ensure => present,
  require => Exec["apt-get update"],
}

# Install Tesseract (version 3.2.2 or greater only!) and Leptonica
package { 'tesseract-ocr' :
  ensure => present,
  require => Exec["apt-get update"],
}


## Set PHP limits per
## http://stackoverflow.com/questions/10800199/set-config-value-in-php-ini-with-puppet
## and https://wiki.duraspace.org/display/ISLANDORA713/Installing+Drupal
php::set_php_var{ 'post_max_size' :
  value => '2048M', }
php::set_php_var{ 'upload_max_filesize' :
  value => '2048M', }
php::set_php_var { 'memory_limit' :
  value => '256M', }
php::set_php_var { 'max_execution_time' :
  value => '600', }                         # MAM added 1024-Aug-15

## Comment out 'bind-address           = 127.0.0.1' line in /etc/mysql/my.cnf to
## mimic Drupal auth filter changes made by Nelson Hart on July 16, 2014.
file_line { 'comment-bind-address' :
  path  => '/etc/mysql/my.cnf',
  line  => "# bind-address           = 127.0.0.1",
  match => 'bind-address',
  require => Service['mysql'],
}

## Attention!  The following are modifications required for DG7, and I'm not sure why.  8^(
# Fix .islandora-pdf-content width in CSS
exec { "sed -i 's/width: auto;/width: 100%;/g' ${drupal_path}/sites/all/modules/contrib/islandora_solution_pack_pdf/css/islandora_pdf.theme.css" :
  require => Vcsrepo[ "${drupal_path}/sites/all/modules/contrib/islandora_solution_pack_pdf" ],
  path    => "/bin:/usr/bin",
}

// @TODO:  Roll in my custom modules... Repository Control and FOC (Fedora Object Control)


