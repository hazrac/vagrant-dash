class packages::python {

  include packages::aptget

  package { 'python':
    ensure => present,
  }

  package { 'python-pip':
     ensure => present,
  }

}
