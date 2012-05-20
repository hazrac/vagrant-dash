class graphite::buildenv {

  include graphite::params

  file { "${graphite::params::build_dir}":
    ensure => directory,
    recurse => true,
    purge => true,
    backup => false,
  }
  
}
