## This is the init.pp manifest for the Puppet "webmin" module.  This code
## originally forked from http://projects.puppetlabs.com/projects/1/wiki/Webmin_Patterns

class webmin {
    # monit::package { "webmin": }

    $base = "webmin_1.680_all.deb"
    $url = "http://prdownloads.sourceforge.net/webadmin/"
    $archive = "/root/$base"
    $installed = "/etc/webmin/version"

    $webmin_packages = [
      "perl ",
      "libnet-ssleay-perl ",
      "openssl ",
      "libauthen-pam-perl ",
      "libpam-runtime ",
      "libio-pty-perl ",
      "apt-show-versions ",
      "python "
    ]

    package { perl : ensure => installed }
      package { perl-base : ensure => installed }
      package { perl-modules : ensure => installed }
    package { libnet-ssleay-perl : ensure => installed }
    package { openssl : ensure => installed }
    package { libauthen-pam-perl : ensure => installed }
    package { libpam-runtime : ensure => installed }
    package { libio-pty-perl : ensure => installed }
    package { apt-show-versions : ensure => installed }
      package { libapt-pkg-perl : ensure => installed }
    package { python : ensure => installed }
      package { python-minimal : ensure => installed }

    service { webmin:
        ensure => running,
        require => Exec["InstallWebmin"],
        provider => init;
    }

    exec { "DownloadWebmin":
        cwd => "/root",
        command => "wget $url$base",
        creates => $archive,
    }

    exec { "InstallWebmin":
        cwd => "/root",
#       command => "dpkg --install $archive",
        command => "dpkg --install $archive; apt-get -q -y -f install ",
        creates => $installed,
        require => Exec[ "DownloadWebmin" ],
        notify => Service[webmin],
    }

}