class packages::graphitewhisper {

  include packages::graphiteparams
  
  exec { "download-whisper":
    command => "/usr/bin/wget -O $graphiteparams::whisper_dl_loc $graphiteparams::whisper_dl_url",
    creates => "$graphiteparams::whisper_dl_loc",
    require => File["$graphiteparams::build_dir"],
  }

  exec { "unpack-whisper":
    command     => "/bin/tar -zxvf $graphiteparams::whisper_dl_loc ; cd whisper-0.9.9 ;",
    cwd         => "$graphiteparams::build_dir",
    subscribe   => Exec["download-whisper"],
    refreshonly => true
  }

  exec { "install-whisper":
    # true is needed to work around a problem with execs and built ins. https://projects.puppetlabs.com/issues/4884
    command => "/usr/bin/python setup.py install",
    cwd     => "$graphiteparams::build_dir/whisper-0.9.9",
    require => Exec["unpack-whisper"],
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

