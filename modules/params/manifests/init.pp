## This params class created by Mark McFate to augment Puppet creation of !!!!02!!!!.
#
class params {

  ## Define some required parameters
  $node = '!!!!02!!!!'                      ## Attention!
  $my_hostname = "${node}.!!!!04!!!!"      ## Attention!
  $master_password = '!!!!07!!!!'        ## Attention!
  $database = '!!!!08!!!!'                      ## Attention!
  $admin_email = 'digital@!!!!03!!!!'      ## Attention!
  $pid_namespace = 'grinnell'                ## Attention!

  ## The following describe the 'front-end' (Islandora/Drupal) server, not this back-end!
  ## For purposes of configuring the Drupal auth filter, filter-drupal.xml.
  $front_end_hostname = '!!!!01!!!!'
  $front_end_database = '!!!!06!!!!'
  $front_end_db_user = 'digital'
  $front_end_db_password = '!!!!05!!!!'

}
