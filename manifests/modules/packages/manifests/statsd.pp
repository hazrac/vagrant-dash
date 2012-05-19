# Basic instructions from: http://geek.michaelgrace.org/2011/09/installing-statsd-on-ubuntu-server-10-04/

class packages::statsd {
  include packages::aptget

file { '/opt/statsd':
    ensure   => directory,
    owner    => root,
    recurse  => true,
    checksum => md5,
    source   =>'puppet:///modules/packages/statsd/statsd',
  }

file { '/etc/init/statsd.conf':
    ensure   => present,
    owner    => root,
    checksum => md5,
    source   =>'puppet:///modules/packages/statsd/init/statsd.conf',
  }

file { '/etc/init.d/statsd':
    ensure   => link,
    target   => '/lib/init/upstart-job',
  }

  package { 'python-software-properties':
  	    provider => apt,
	    ensure   => present,
            require  => Exec['/usr/bin/apt-get update'],
  }

  package { 'git-core':
  	    provider => apt,
	    ensure   => present,
            require  => Exec['/usr/bin/apt-get update'],
  }

  package { 'nodejs':
  	    provider => apt,
	    ensure   => present,
            require  => Exec['/usr/bin/apt-get update'],
  }

  package { 'npm':
  	    provider => apt,
	    ensure   => present,
            require  => Exec['/usr/bin/apt-get update'],
  }

}
