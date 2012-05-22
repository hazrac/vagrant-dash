class packages::graphiteweb {

  include packages::graphiteparams
  include packages::aptget

  $graphiterqdpkgs = ['apache2', 'apache2-mpm-worker', 'apache2-utils', 'apache2.2-common', 'libapr1', 'libaprutil1', 'libaprutil1-dbd-sqlite3', 'python3.1', 'libpython3.1', 'python3.1-minimal', 'libapache2-mod-wsgi', 'libaprutil1-ldap', 'memcached', 'python-cairo-dev', 'python-django', 'python-ldap', 'python-memcache', 'python-pysqlite2', 'sqlite3', 'erlang-os-mon', 'erlang-snmp', 'bzr', 'libapache2-mod-python', 'python-setuptools', 'python-twisted'] 

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
    command     => "/usr/bin/sudo /usr/bin/python setup.py install",
    cwd         => "$graphiteparams::build_dir/graphite-web-0.9.9",
    subscribe   => Exec["unpack-webapp"],
    refreshonly => true,
    creates     => "/opt/graphite",
  }

  exec { '/usr/bin/easy_install django-tagging':
    require     => Package['python-django'],
    subscribe   => Exec["install-webapp"],
    refreshonly => true,
  }

  exec { "initialize-db":
    command     => "/bin/bash -c 'export PYTHONPATH=/opt/graphite/webapp && /usr/bin/python manage.py syncdb'",
    cwd         => '/opt/graphite/webapp/graphite/',
    subscribe   => Exec["install-webapp"],
    refreshonly => true,
    user        => "$graphiteparams::web_user",
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
    subscribe => Exec['install-webapp'],
  }

  file { "/opt/graphite/conf/graphite.wsgi":
    source    => "puppet:///modules/packages/graphite/conf/graphite.wsgi",
    subscribe => Exec["install-webapp"],
    require   => Package[$graphiterqdpkgs],
  }

  file { "/opt/graphite/storage":
    owner => "$graphiteparams::web_user",
    subscribe => Exec["install-webapp"],
    recurse => inf
  }
}
