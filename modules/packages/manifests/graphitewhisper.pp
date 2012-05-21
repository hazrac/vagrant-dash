class packages::graphitewhisper {

  include packages::graphiteparams
  
  exec { "download-whisper":
    command => "wget -O $graphiteparams::whisper_dl_loc $graphiteparams::whisper_dl_url",
    creates => "$graphiteparams::whisper_dl_loc",
    require => File["$graphiteparams::build_dir"],
  }

  exec { "unpack-whisper":
    # true is needed to work around a problem with execs and built ins. https://projects.puppetlabs.com/issues/4884
    command => "cd $graphiteparams::build_dir ; tar -zxvf $graphiteparams::whisper_dl_loc ; cd whisper-0.9.9 ;",
    subscribe => Exec["download-whisper"],
    refreshonly => true
  }

  exec { "install-whisper":
    # true is needed to work around a problem with execs and built ins. https://projects.puppetlabs.com/issues/4884
    command => "cd $graphiteparams::build_dir/whisper-0.9.9 && python setup.py install",
    require => Exec["unpack-whisper"],
  }

}

