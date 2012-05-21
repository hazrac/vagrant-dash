class packages::graphiteweb {

  include packages::graphiteparams
  include packages::aptget

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
    command     => "/usr/bin/python setup.py install",
    cwd         => "$graphiteparams::build_dir/graphite-web-0.9.9",
    subscribe   => Exec["unpack-webapp"],
    refreshonly => true,
    creates     => "/opt/graphite",
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
    require   => Package['graphiterqdpkgs'],
  }

  file { "/opt/graphite/conf/graphite.wsgi":
    source    => "puppet:///modules/packages/graphite/conf/graphite.wsgi",
    subscribe => Exec["install-webapp"],
    require   => Package['graphiterqdpkgs'],
  }

  file { "/opt/graphite/storage":
    owner => "$graphiteparams::web_user",
    subscribe => Exec["install-webapp"],
    recurse => inf
  }

  package {
    [python-ldap, python-cairo, python-django, python-simplejson, libapache2-mod-wsgi, python-memcache, python-pysqlite2, python-rrdtool]:
      alias   => 'graphiterqdpkgs',
      require => Exec['aptgetupdate'],
      ensure  => latest;
  }
}
