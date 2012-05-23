class packages::graphiteweb {

  include packages::graphiteparams
  include packages::aptget

  $graphiterqdpkgs = ['apache2', 'apache2-mpm-worker', 'apache2-utils', 'apache2.2-common', 'libapr1', 'libaprutil1', 'libaprutil1-dbd-sqlite3', 'python3.1', 'libpython3.1', 'python3.1-minimal', 'libapache2-mod-wsgi', 'libaprutil1-ldap', 'memcached', 'python-cairo-dev', 'python-django', 'python-ldap', 'python-memcache', 'python-pysqlite2', 'sqlite3', 'erlang-os-mon', 'erlang-snmp', 'libapache2-mod-python', 'python-setuptools', 'python-twisted'] 

  package { $graphiterqdpkgs:
      require => Exec['aptgetupdate'],
      ensure  => latest;
  }

  exec { "download-webapp":
    command => "/usr/bin/wget -O $graphiteparams::webapp_dl_loc $graphiteparams::webapp_dl_url",
    creates => "$graphiteparams::webapp_dl_loc",
    require => File["$graphiteparams::build_dir"],
  }

  exec { "unpack-webapp":
    command     => "/bin/tar -zxvf $graphiteparams::webapp_dl_loc",
    cwd         => "$graphiteparams::build_dir",
    subscribe   => Exec["download-webapp"],
    refreshonly => true,
    creates     => "$graphiteparams::build_dir/graphite-web-0.9.9",
  }

  exec { "install-webapp":
    command     => "/usr/bin/python $graphiteparams::build_dir/graphite-web-0.9.9/setup.py install",
    cwd         => "$graphiteparams::build_dir/graphite-web-0.9.9",
    subscribe   => Exec["unpack-webapp"],
    refreshonly => true,
    creates     => "/opt/graphite/webapp",
    user        => "root",
  }

  exec { '/usr/bin/easy_install django-tagging':
    require     => Package['python-django'],
    subscribe   => Exec["install-webapp"],
    refreshonly => true,
  }

  exec { "initialize-db":
    require     => [Exec['/usr/bin/easy_install django-tagging'], Exec["install-webapp"]],
    command     => '/usr/bin/python manage.py syncdb --noinput',
    cwd         => '/opt/graphite/webapp/graphite',
    #refreshonly => true,
    user        => "root",
  }

  file { "$graphiteparams::apacheconf_dir/graphite.conf":
    source    => "puppet:///modules/packages/graphite/conf/graphite-vhost.conf",
    subscribe => Exec['install-webapp'],
    require   => Package[$graphiterqdpkgs],
  }

  file { 'local_settings.py':
    ensure    => file,
    path      => '/opt/graphite/webapp/graphite/local_settings.py',
    owner     => root,
    source    => 'puppet:///modules/packages/graphite/conf/local_settings.py',
    require   => Exec["install-webapp"],
  }

  file { "/opt/graphite/conf/graphite.wsgi":
    source    => "puppet:///modules/packages/graphite/conf/graphite.wsgi",
    subscribe => Exec["install-webapp"],
    require   => Package[$graphiterqdpkgs],
  }

  file { "/opt/graphite/storage":
    owner     => "$graphiteparams::web_user",
    subscribe => Exec["install-webapp"],
    recurse   => inf
  }

  file { '/etc/httpd':
    ensure  => directory,
    path    => '/etc/httpd',
    owner   => root,
  }

  file { '/etc/httpd/wsgi':
    ensure  => directory,
    path    => '/etc/httpd/wsgi',
    owner   => root,
    require => File['/etc/httpd'],
  }

}
