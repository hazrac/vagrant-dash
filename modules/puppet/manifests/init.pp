class puppet {
  include aptget

  package { 'facter':
    ensure   => present,
    require  => Exec['aptgetupdate'],
  }

}
