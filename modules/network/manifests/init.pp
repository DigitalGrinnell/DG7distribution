## This class created by Mark McFate to augment networking in the DG environment.
#
class network {

  file_line { 'add-!!!!02!!!!' :
    path  => '/etc/hosts',
    line  => '192.168.1.100 !!!!02!!!!.!!!!04!!!!',
    match => '192\.168\.1\.100',
  }

  file_line { 'add-!!!!01!!!!' :
    path  => '/etc/hosts',
    line  => '192.168.1.101 !!!!01!!!!.!!!!04!!!!',
    match => '192\.168\.1\.101',
  }

}
