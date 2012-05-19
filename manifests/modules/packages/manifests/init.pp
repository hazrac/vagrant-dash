class packages {
  include packages::aptget

  package { 'facter':
    ensure => present,
  }

  package { 'dkms':
    ensure => present,
  } 

}
