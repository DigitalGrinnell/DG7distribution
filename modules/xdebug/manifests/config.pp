define xdebug::config (
    #Template variables
    $ini_file_path    = '/etc/php5/apache2/conf.d/20-xdebug.ini',     # MAM for Ubuntu 14.04
    $default_enable   = '',
    $remote_enable    = '',
    $remote_handler   = '',
    $remote_host      = '',
    $remote_port      = '',
    $remote_autostart = '',
  )
{

    #Template variables default values
    $xdebug_ini_file_path = $ini_file_path ? {
        ''      => '/etc/php5/conf.d/xdebug_config.ini',
        default => $ini_file_path,
    }

    $xdebug_default_enable = $default_enable ? {
        ''      => '1',
        default => $default_enable,
    }

    $xdebug_remote_enable = $remote_enable ? {
        ''      => '1',
        default => $remote_enable,
    }

    $xdebug_remote_handler = $remote_handler ? {
        ''      => 'dbgp',
        default => $remote_handler,
    }

    $xdebug_remote_host = $remote_host ? {
        ''      => 'localhost',
        default => $remote_host,
    }

    $xdebug_remote_port = $remote_port ? {
        ''      => '9000',
        default => $remote_port,
    }

    $xdebug_remote_autostart = $remote_autostart ? {
        ''      => '1',
        default => $remote_autostart,
    }

    file { "$xdebug_ini_file_path" :
        content => template('xdebug/ini_file.erb'),
        ensure  => present,
        require => Package['xdebug'],
        notify  => Service['apache2'],
    }

TODO !!!!!!!!!!!!!!!!
## MAM - Add the following lines to php.ini
# ; For XDebug
# zend_extension="/usr/lib/php5/20121212/xdebug.so"
# xdebug.remote_enable=1
# xdebug.remote_handler=dbgp
# xdebug.remote_mode=req
# xdebug.remote_connect_back=1
# xdebug.remote_port=9000




}