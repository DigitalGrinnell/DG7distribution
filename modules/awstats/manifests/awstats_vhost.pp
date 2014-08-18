define awstats::awstats_vhost($ensure = present, $docroot, $outputdir, $user,
  $group, $domain, $aliases, $apache_package_name = 'apache2', $conf_template = 'awstats/awstats.conf.erb') {
  file { "/etc/awstats/awstats.${name}.conf":
    ensure  => $ensure,
    require => [
      Package[$apache_package_name],
      File[$docroot],
#     User[$name]  ## MAM - makes no sense to me?
#     User[$user]  ## MAM - this makes more sense, but should not be 'required' since I explicitly require Service[apache2] in the default manifest
    ],
    mode    => 0644,
    owner   => $user,
    group   => $group,
    content => template($conf_template),
  }



  cron { "awstats-update-run-${name}":
    ensure  => $ensure,
    command => "/usr/bin/perl /usr/share/doc/awstats/examples/awstats_buildstaticpages.pl -config=${name} -update -awstatsprog=/usr/lib/cgi-bin/awstats.pl -dir=${outputdir} -diricons=/awstats/awstats-icon/",
    user    => $user,
    minute  => [1, 11, 21, 31, 41, 51],
#   require => User[$user]  ## MAM - should not be required since I explicity require Service[apache2] in the default manifest.
  }

}
