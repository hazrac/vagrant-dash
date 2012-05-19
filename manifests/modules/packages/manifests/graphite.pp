class packages::graphite {


        include packages::aptget

	# Get all the packages we need
	$graphite_packages = ['apache2', 'apache2-mpm-worker', 'apache2-utils', 'apache2.2-common', 'libapr1', 'libaprutil1', 'libaprutil1-dbd-sqlite3', 'python3.1', 'libpython3.1', 'python3.1-minimal', 'libapache2-mod-wsgi', 'libaprutil1-ldap', 'memcached', 'python-cairo-dev', 'python-django', 'python-ldap', 'python-memcache', 'python-pysqlite2', 'sqlite3', 'erlang-os-mon', 'erlang-snmp', 'bzr', 'libapache2-mod-python', 'python-setuptools', 'python-twisted']

	# Define the versions of graphite, carbon, and whisper
	$graphiteweb = 'graphite-web-0.9.9.tar.gz'
	$carbon = 'carbon-0.9.9.tar.gz'
	$whisper = 'whisper-0.9.9.tar.gz'

	package { $graphite_packages:
		ensure   => present,
		provider => apt,
		require  => Exec['aptgetupdate'],
	}

	# TODO - Could you use a conditional to run this once?
	file { $graphiteweb:
		ensure	    => file,
		path	    => "/tmp/${graphiteweb}",
		source	    => "puppet:///modules/packages/graphite/${graphiteweb}",
	}
	file { $carbon:
		ensure	    => file,
		path	    => "/tmp/${carbon}",
		source	    => "puppet:///modules/packages/graphite/${carbon}",
	}
	file { $whisper:
		ensure	=> file,
		path	=> "/tmp/${whisper}",
		source	=> "puppet:///modules/packages/graphite/${whisper}",
	}

	# Installs Graphite-Web
	$graphite_untar = "/bin/tar -C /tmp/ -zxvf /tmp/${graphiteweb} && /bin/mv /tmp/graphite-web-0.9.9 /tmp/graphite"
	exec { $graphite_untar :
		creates => '/tmp/graphite',
		require => File[$graphiteweb],
	}
	exec { '/usr/bin/python /tmp/graphite/setup.py install':
		require => Exec[$graphite_untar],
		cwd => '/tmp/graphite',
	}
	file { 'graphite-vhost.conf':
		ensure	=> file,
		path	=> '/etc/apache2/sites-available/default',
	 	owner 	=> root,	
		source	=> 'puppet:///modules/packages/graphite/conf/graphite-vhost.conf',
		require => Package['apache2'],
	}
	file { 'graphite.wsgi':
		ensure	=> file,
		path	=> '/opt/graphite/conf/graphite.wsgi',
	 	owner 	=> root,	
		source	=> 'puppet:///modules/packages/graphite/conf/graphite.wsgi',
		require => Exec['/usr/bin/python /tmp/graphite/setup.py install'],
	}
	file { '/etc/httpd':
		ensure	=> directory,
		path	=> '/etc/httpd',
	 	owner 	=> root,	
	}
	file { '/etc/httpd/wsgi':
		ensure	=> directory,
		path	=> '/etc/httpd/wsgi',
	 	owner 	=> root,	
		require => File['/etc/httpd'],
	}

	# Installs Carbon
	$carbon_untar =	"/bin/tar -C /tmp/ -zxvf /tmp/${carbon} && /bin/mv /tmp/carbon-0.9.9 /tmp/carbon"
	exec { $carbon_untar :
		creates => '/tmp/carbon',
		require => File[$carbon],
	}
	exec { '/usr/bin/python /tmp/carbon/setup.py install':
		require => Exec[$carbon_untar],
		cwd => '/tmp/carbon',
	}
	file { 'storage-schemas.conf':
		ensure	=> file,
		path	=> '/opt/graphite/conf/storage-schemas.conf',
	 	owner 	=> root,	
		source	=> 'puppet:///modules/packages/graphite/conf/storage-schemas.conf',
		require => Exec['/usr/bin/python /tmp/carbon/setup.py install'],
	}
	file { 'carbon.conf':
		ensure	=> file,
		path	=> '/opt/graphite/conf/carbon.conf',
	 	owner 	=> root,	
		source	=> 'puppet:///modules/packages/graphite/conf/carbon.conf',
		require => Exec['/usr/bin/python /tmp/carbon/setup.py install'],
	}
	file { 'carbon-cache.init':
		ensure	=> file,
		path	=> '/etc/init.d/carbon-cache',
	 	owner 	=> root,	
		group 	=> root,
		mode	=> '0744',
		source	=> 'puppet:///modules/packages/graphite/init/carbon-cache.init',
	}
	service { 'carbon-cache':
		ensure     => running,
		hasrestart => false,
		hasstatus  => false,
		start      => '/etc/init.d/carbon-cache start',
		subscribe  => File['carbon.conf'],
		require    => File['carbon-cache.init'],
	}

	# Installs Whisper
        $whisper_untar = "/bin/tar -C /tmp/ -zxvf /tmp/${whisper} && /bin/mv /tmp/whisper-0.9.9 /tmp/whisper"	
	exec { $whisper_untar :
		creates => '/tmp/whisper',
		require => File[$whisper],
	}
	exec { '/usr/bin/python /tmp/whisper/setup.py install':
		require => Exec[$whisper_untar],
		cwd => '/tmp/whisper',	
	}
	exec { '/usr/bin/easy_install django-tagging':
		require => Package['python-django'],
	}

	# Sets up initial DB
	#TODO ISSUES HERE
	exec { '/usr/bin/sudo /usr/bin/python /opt/graphite/webapp/graphite/manage.py syncdb':
	        alias   => 'syncdb',
		require => Exec['/usr/bin/python /tmp/graphite/setup.py install'],
	}
	file { '/opt/graphite/storage':
		ensure	  => directory,
		path	  => '/opt/graphite/storage',
	 	owner 	  => www-data,	
		group	  => www-data,
		recurse   => true,
		require   => Exec['syncdb'],
                subscribe => Exec['syncdb'],
	}
	file { 'local_settings.py':
		ensure	=> file,
                path	=> '/opt/graphite/webapp/graphite/local_settings.py',
	 	owner 	=> root,	
		source	=> 'puppet:///modules/packages/graphite/conf/local_settings.py',
		require => Exec['/usr/bin/python /tmp/graphite/setup.py install'],
	}
	# Ensure Apache is running
	service { 'apache2':
		ensure     => running,
		hasrestart => true,
		hasstatus  => true,
		subscribe  => File['/etc/httpd/wsgi'],
                require    => Package['apache2'],
	}
}
