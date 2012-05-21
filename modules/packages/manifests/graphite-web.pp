class packages::graphite-web {

  include packages::graphite-params
  include packages::aptget

  exec { "download-webapp":
    command => "wget -O $graphite-params::webapp_dl_loc $graphite-params::webapp_dl_url",
    creates => "$graphite-params::webapp_dl_loc",
    require => File["$graphite-params::build_dir"],
  }

  exec { "unpack-webapp":
    # true is needed to work around a problem with execs and built ins. https://projects.puppetlabs.com/issues/4884 -- I believe this is fixed
    command => "bash -c 'cd $graphite-params::build_dir && tar -zxvf $graphite-params::webapp_dl_loc",
    subscribe => Exec["download-webapp"],
    refreshonly => true,
    creates => "$graphite-params::build_dir/graphite-web-0.9.9",
  }

  exec { "install-webapp":
    # true is needed to work around a problem with execs and built ins. https://projects.puppetlabs.com/issues/4884 -- I believe this is fixed
    command => "cd $graphite-params::build_dir/graphite-web-0.9.9 && python setup.py install",
    subscribe => Exec["unpack-webapp"],
    refreshonly => true,
    creates => "/opt/graphite",
  }

  exec { "initialize-db":
    command     => "/bin/bash -c 'export PYTHONPATH=/opt/graphite/webapp && /usr/bin/python manage.py syncdb'",
    cwd         => '/opt/graphite/webapp/graphite/',
    subscribe   => Exec["install-webapp"],
    refreshonly => true,
    user        => "$graphite-params::web_user",
  }

  file { "$graphite-params::apacheconf_dir/graphite.conf":
    source => "puppet:///modules/graphite/graphite-apache-vhost.conf" ,
    subscribe => Exec["install-webapp"],
  }

  file { "/opt/graphite/conf/graphite.wsgi":
    source => "puppet:///modules/graphite/graphite.wsgi",
    subscribe => Exec["install-webapp"],
  }

  file { "/opt/graphite/storage":
    owner => "$graphite-params::web_user",
    subscribe => Exec["install-webapp"],
    recurse => inf
  }

  package {
    [python-ldap, python-cairo, python-django, python-simplejson, libapache2-mod-wsgi, python-memcache, python-pysqlite2, python-rrdtool]:
      require => Exec['aptgetupdate'],
      ensure  => latest;
  }
}
