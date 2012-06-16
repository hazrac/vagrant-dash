class aptget {

  file { '/etc/apt':
    ensure   => directory,
    owner    => root,
    recurse  => true,
    checksum => md5,
    source   => 'puppet:///modules/aptget/apt',
  }

  exec { '/usr/bin/apt-get update':
     alias       => 'aptgetupdate',
     require     => File['/etc/apt'],
     subscribe   => File['/etc/apt'],
     refreshonly => true;
  }

}
