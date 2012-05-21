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

}
