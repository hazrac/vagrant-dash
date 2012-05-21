class packages::graphite {



	## THESE DON'T exist in the new config - need to confirm if they should
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

        # Will need somewhere
	# Ensure Apache is running
	service { 'apache2':
		ensure     => running,
		hasrestart => true,
		hasstatus  => true,
		subscribe  => File['/etc/httpd/wsgi'],
                require    => Package['apache2'],
	}


}
