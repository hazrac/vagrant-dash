class graphite::python {

  include aptget

  package { 'python':
    ensure => present,
  }

  package { 'python-pip':
     ensure => present,
  }

}
