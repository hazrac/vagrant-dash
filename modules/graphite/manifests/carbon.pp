class packages::carbon {

 include packages::graphiteparams
 include packages::aptget

 exec { "download-carbon":
    command => "/usr/bin/wget -O $graphiteparams::carbon_dl_loc $graphiteparams::carbon_dl_url",
    creates => "$graphiteparams::carbon_dl_loc",
    require => File["$graphiteparams::build_dir"],
  }

  exec { "unpack-carbon":
    command     => "/bin/tar -zxvf $graphiteparams::carbon_dl_loc",
    cwd         => "$graphiteparams::build_dir",
    subscribe   => Exec["download-carbon"],
    refreshonly => true,
    creates     => "$graphiteparams::build_dir/carbon-0.9.9",
  }

   exec { "install-carbon":
           # This doesn't work
           command   => "/bin/bash -c 'PYTHONPATH=/opt/graphitewebapp:/opt/graphite/whisper /usr/bin/python $graphiteparams::build_dir/carbon-0.9.9/setup.py install'",
           subscribe => Exec["unpack-carbon"],
           cwd       => "$graphiteparams::build_dir/carbon-0.9.9",
   }
   file { 'storage-schemas.conf':
           ensure    => file,
           path      => '/opt/graphite/conf/storage-schemas.conf',
           owner     => root,
           source    => 'puppet:///modules/packages/graphite/conf/storage-schemas.conf',
           subscribe => Exec["install-carbon"],
   }
   file { 'carbon.conf':
           ensure    => file,
           path      => '/opt/graphite/conf/carbon.conf',
           owner     => root,
           source    => 'puppet:///modules/packages/graphite/conf/carbon.conf',
           subscribe => Exec["install-carbon"],
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
