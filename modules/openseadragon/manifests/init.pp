## This is the init.pp manifest for the Puppet "openseadragon" module.  This manifest
## adapted by Mark McFate from a djatoka script originally forked
## from http://projects.puppetlabs.com/projects/1/wiki/Webmin_Patterns
##
## The process employed here is also based largely on http://v2p2dev.to.cnr.it/doku.php?id=isla2:limage.

class openseadragon {

    $base = "openseadragon"
    $version = "${base}-bin-1.0.0"
    $tar = "${version}.tar"
    $gz = "${tar}.gz"
    $url = "https://github.com/openseadragon/openseadragon/releases/download/v1.0.0/${gz}"
    $archive = "/root/${gz}"
    $target = "${drupal_path}/sites/all/libraries"
    $installed = "/${target}/${base}"

    exec { 'Download_OpenSeadragon' :
        cwd => "/root",
        command => "wget '${url}'",
        creates => "${archive}",
    }

    exec { "Install_OpenSeadragon" :
        cwd => "/root",
        command => "/bin/gunzip ${archive}; /bin/tar -xvf ${tar}; mv -f ${version} ${base}; mv -f ${base} ${target}/",
        creates => "${installed}",
        require => [ Exec[ "Download_OpenSeadragon" ], File[ "${drupal_path}/sites/all/libraries" ], ],
    }

    exec { "Cleanup_OpenSeadragon" :
        cwd => "/root",
        command => "rm -f ${base}*",
        require => Exec[ "Install_OpenSeadragon" ],
    }

## Enable reverse proxy to adore-djatoka
## Path to Kakadu: /usr/local/bin/kdu_compress Viewers: OpenSeadragon

    exec { "Enable_Reverse_Proxy" :
        cwd => "/etc/apache2/sites-enabled",
        command => "a2enmod cache proxy proxy_http",
#       require => Exec[ "Cleanup_OpenSeadragon" ],
        notify => Service["apache2"],
    }

    vcsrepo { "${drupal_path}/sites/all/modules/contrib/islandora_openseadragon" :
      source => "git://github.com/Islandora/islandora_openseadragon.git", }

}

