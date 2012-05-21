class packages::graphite {



	## Do I need these for the 'new way' of installing?
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
		require => File['graphite-vhost.conf'],
	}
	file { '/opt/graphite/storage':
		ensure	  => directory,
		path	  => '/opt/graphite/storage',
	 	owner 	  => www-data,	
		group	  => www-data,
		recurse   => true,
		require   => Exec['/usr/bin/python /tmp/graphite/setup.py install'],
                subscribe => Exec['/usr/bin/python /tmp/whisper/setup.py install'],
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
