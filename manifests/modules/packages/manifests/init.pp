class packages {
  include packages::aptget

  package { 'facter':
    ensure   => present,
    require  => Exec['aptgetupdate'],
  }

  package { 'dkms':
    ensure   => present,
    require  => Exec['aptgetupdate'],
  } 

}
