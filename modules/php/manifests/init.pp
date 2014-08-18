class php {

  # package install list
  $packages = [
    "php5",
    "php5-cli",
    "php5-mysql",
    "php-pear",
    "php5-dev",
    "php5-gd",
    "php5-mcrypt",
    "libapache2-mod-php5",
    "php5-xsl",             ## MAM this and below added per Drupal install requirements
    "php5-curl",
    "php-soap",
  ]

  package { $packages :
    ensure => present,
    require => Exec["apt-get update"]
  }

  ## Per http://stackoverflow.com/questions/10800199/set-config-value-in-php-ini-with-puppet

  define set_php_var( $value ) {
    exec { "sed -i 's/^;*[[:space:]]*$name[[:space:]]*=.*$/$name = $value/g' /etc/php5/apache2/php.ini":
      unless  => "grep -xqe '$name[[:space:]]*=[[:space:]]*$value' -- /etc/php5/apache2/php.ini",
      path    => "/bin:/usr/bin",
      require => Package[php5],
      notify  => Service[apache2],
    }
  }

}
