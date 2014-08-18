class !!!!01!!!!-grinnell {

  $!!!!01!!!!_packages = [
    "xpdf-utils",   # MAM added 01-Jul-2014 for PDF Solution Pack dependency
    "node",         # MAM added 01-Jul-2014 for pdf.js build dependency
    "ghostscript",  # MAM added 03-Jul-2014 for Paged Content Solution Pack
  ]

  # install packages
  package { $!!!!01!!!!_packages :
    ensure => present,
    require => Exec["apt-get update"]
  }

  ## Create a default MySQL database.
  exec { "mysql-db-create-${database}" :
    command => "mysql -uroot -p${mysql_root_password} -e \"CREATE DATABASE IF NOT EXISTS ${database}\"",
    require => Exec[ 'set-mysql-password' ],
  }

  ## Create a $user system and MySQL user and add it to the target database.  Grant $user ALL privileges
  ## from ALL (%) hosts.
  $mysql_user = $user
  exec { "mysql-user-create-${mysql_user}" :
#     command => "mysql -uroot -p${mysql_root_password} -e \"GRANT ALL PRIVILEGES ON *.* TO '${mysql_user}'@'localhost' IDENTIFIED BY '${master_password}'; FLUSH PRIVILEGES;\"",
      command => "mysql -uroot -p${mysql_root_password} -e \"GRANT ALL PRIVILEGES ON *.* TO '${mysql_user}'@'%' IDENTIFIED BY '${master_password}'; FLUSH PRIVILEGES;\"",
      require => [
        Exec[ 'set-mysql-password' ],
        Exec[ "mysql-db-create-${database}" ],
        User[ "${user}" ],
      ],
    }

  ## Roll in the necessary (and pre-populated) Drupal site settings.php file.
  file { "${drupal_path}/sites/default/settings.php" :
    ensure => present,
    source => "puppet:///modules/!!!!01!!!!-grinnell/settings.php",
    owner => $user,
    group => www-data,
    mode  => 444,
    require => File[ "${drupal_path}/sites/default" ];
  }

  ## Roll in the entire ../sites/default/files folder.
  file { "${drupal_path}/sites/default/files" :
    source  => "puppet:///modules/!!!!01!!!!-grinnell/files",
    recurse => true,
    owner => www-data,
    group => www-data,
    mode  => 764,
    require => File[ "${drupal_path}/sites/default" ],
  }

  ## Roll in the entire ../sites/default/themes folder.
  file { "${drupal_path}/sites/default/themes" :
    source  => "puppet:///modules/!!!!01!!!!-grinnell/themes",
    recurse => true,
    owner => $user,
    group => www-data,
    mode  => 764,
    require => File[ "${drupal_path}/sites/default" ],
  }

  ## Restore the backup of the 'reset' default database.
  exec { 'restore-default-database' :
    command => "/usr/bin/mysql -u${user} -p${mysql_root_password} ${database} < reset.mysql",
    cwd => "${drupal_path}/sites/default/files/backup_migrate/manual",
    require => [ File[ "${drupal_path}/sites/default/files" ],
                 Service[ "mysql" ], ],
  }

  ## Turn "maintenace mode" off in the default site.
  drush::exec { 'maintenace-mode-off' :
    command => 'vset maintenance_mode 0',
    require => [ File[ "${drupal_path}/sites/default/settings.php" ],
                 Service[ 'mysql' ],
                 Package[ 'drush' ],
                 Exec[ 'restore-default-database' ],
    ],
  }

}
