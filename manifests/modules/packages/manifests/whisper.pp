class packages::graphite::whisper {

  include packages::graphite::params
  
  exec { "download-whisper":
    command => "wget -O $packages::graphite::params::whisper_dl_loc $packages::graphite::params::whisper_dl_url",
    creates => "$packages::graphite::params::whisper_dl_loc",
    require => File["$packages::graphite::params::build_dir"],
  }

  exec { "unpack-whisper":
    # true is needed to work around a problem with execs and built ins. https://projects.puppetlabs.com/issues/4884
    command => "cd $packages::graphite::params::build_dir ; tar -zxvf $packages::graphite::params::whisper_dl_loc ; cd whisper-0.9.9 ;",
    subscribe => Exec["download-whisper"],
    refreshonly => true
  }

  exec { "install-whisper":
    # true is needed to work around a problem with execs and built ins. https://projects.puppetlabs.com/issues/4884
    command => "cd $packages::graphite::params::build_dir/whisper-0.9.9 && python setup.py install",
    require => Exec["unpack-whisper"],
  }

}

