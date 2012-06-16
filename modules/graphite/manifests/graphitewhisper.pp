class graphite::graphitewhisper {

  include graphite::graphiteparams
  
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

}
