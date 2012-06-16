class graphite {
  include aptget

  # I don't recall why I need this, need to verify
  package { 'dkms':
    ensure   => present,
    require  => Exec['aptgetupdate'],
  } 

}
