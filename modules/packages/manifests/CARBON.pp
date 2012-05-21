class packages::carbon {

   # Installs Carbon -- NEEDS TO USE VARS AND PULL WITH WGET
   $carbon_untar = "/bin/tar -C /tmp/ -zxvf /tmp/${carbon} && /bin/mv /tmp/carbon-0.9.9 /tmp/carbon"
   exec { $carbon_untar :
           creates => '/tmp/carbon',
           require => File[$carbon],
   }
   exec { '/usr/bin/python /tmp/carbon/setup.py install':
           require => Exec[$carbon_untar],
           cwd => '/tmp/carbon',
   }
   file { 'storage-schemas.conf':
           ensure  => file,
           path    => '/opt/graphite/conf/storage-schemas.conf',
           owner   => root,
           source  => 'puppet:///modules/packages/graphite/conf/storage-schemas.conf',
           require => Exec['/usr/bin/python /tmp/carbon/setup.py install'],
   }
   file { 'carbon.conf':
           ensure  => file,
           path    => '/opt/graphite/conf/carbon.conf',
           owner   => root,
           source  => 'puppet:///modules/packages/graphite/conf/carbon.conf',
           require => Exec['/usr/bin/python /tmp/carbon/setup.py install'],
   }
   file { 'carbon-cache.init':
           ensure  => file,
           path    => '/etc/init.d/carbon-cache',
           owner   => root,
           group   => root,
           mode    => '0744',
           source  => 'puppet:///modules/packages/graphite/init/carbon-cache.init',
   }
   service { 'carbon-cache':
           ensure     => running,
           hasrestart => false,
           hasstatus  => false,
           start      => '/etc/init.d/carbon-cache start',
           subscribe  => File['carbon.conf'],
           require    => File['carbon-cache.init'],
   }
}
