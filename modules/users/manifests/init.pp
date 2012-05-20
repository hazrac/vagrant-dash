class users {

# Need to put your own username and password here 
#  user { "username":
#    ensure => present,
#    uid => '507',
#    shell => '/bin/bash',
#    home => '/home/username',
#    password => '',
#    managehome => true,
#  }

  user { "puppet": 
    ensure => present,
  }

}
