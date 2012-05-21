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

        ##  Is this needed for storage config??
	file { 'storage-schemas.conf':
		ensure	=> file,
		path	=> '/opt/graphite/conf/storage-schemas.conf',
	 	owner 	=> root,	
		source	=> 'puppet:///modules/packages/graphite/conf/storage-schemas.conf',
		require => Exec['/usr/bin/python /tmp/carbon/setup.py install'],
	}

        ## Is this needed for carbon config??
	file { 'carbon.conf':
		ensure	=> file,
		path	=> '/opt/graphite/conf/carbon.conf',
	 	owner 	=> root,	
		source	=> 'puppet:///modules/packages/graphite/conf/carbon.conf',
		require => Exec['/usr/bin/python /tmp/carbon/setup.py install'],
	}

        ### ?????
	exec { '/usr/bin/easy_install django-tagging':
		require => Package['python-django'],
	}

	#TODO ISSUES HERE
	exec { '/usr/bin/sudo /usr/bin/python /opt/graphite/webapp/graphite/manage.py syncdb':
		require => File['graphite-vhost.conf'],
	}


        ##  Again, needed?	
	file { 'local_settings.py':
		ensure	=> file,
                path	=> '/opt/graphite/webapp/graphite/local_settings.py',
	 	owner 	=> root,	
		source	=> 'puppet:///modules/packages/graphite/conf/local_settings.py',
		require => Exec['/usr/bin/python /tmp/graphite/setup.py install'],
	}

        # Will need somewhere
	# Ensure Apache is running
	service { 'apache2':
		ensure     => running,
		hasrestart => true,
		hasstatus  => true,
		subscribe  => File['/etc/httpd/wsgi'],
                require    => Package['apache2'],
	}

  ## Perhaps this should go in a graphite services dir?
  file { 'carbon-cache.init':
    ensure  => file,
    path    => '/etc/init.d/carbon-cache',
    owner   => root,
    group   => root,
    mode    => '0744',
    source  => 'puppet:///modules/packages/graphite/init/carbon-cache.init',
  }
  service { 'carbon-cache':
    ensure     => running,
    hasrestart => false,
    hasstatus  => false,
    start      => '/etc/init.d/carbon-cache start',
    subscribe  => File['carbon.conf'],
    require    => File['carbon-cache.init'],
  }

}
