class packages::graphite-web {

  include packages::graphite-params
  include packages::aptget

  exec { "download-webapp":
    command => "wget -O $packages::graphite-params::webapp_dl_loc $packages::graphite-params::webapp_dl_url",
    creates => "$packages::graphite-params::webapp_dl_loc",
    require => File["$packages::graphite-params::build_dir"],
  }

  exec { "unpack-webapp":
    # true is needed to work around a problem with execs and built ins. https://projects.puppetlabs.com/issues/4884 -- I believe this is fixed
    command => "bash -c 'cd $packages::graphite-params::build_dir && tar -zxvf $packages::graphite-params::webapp_dl_loc",
    subscribe => Exec["download-webapp"],
    refreshonly => true,
    creates => "$packages::graphite-params::build_dir/graphite-web-0.9.9/",
  }

  exec { "install-webapp":
    # true is needed to work around a problem with execs and built ins. https://projects.puppetlabs.com/issues/4884 -- I believe this is fixed
    command => "cd $packages::graphite-params::build_dir/graphite-web-0.9.9 && python setup.py install",
    subscribe => Exec["unpack-webapp"],
    refreshonly => true,
    creates => "/opt/graphite",
  }

  exec { "initialize-db":
    command => "bash -c 'export PYTHONPATH=/opt/graphite/webapp &&  cd /opt/graphite/webapp/graphite/ && python manage.py syncdb'",
    subscribe => Exec["install-webapp"],
    refreshonly => true,
    user => $packages::graphite-params::web_user,
  }

  file { "$packages::graphite-params::apacheconf_dir/graphite.conf":
    source => "puppet:///modules/graphite/graphite-apache-vhost.conf" ,
    subscribe => Exec["install-webapp"],
  }

  file { "/opt/graphite/conf/graphite.wsgi":
    source => "puppet:///modules/graphite/graphite.wsgi",
    subscribe => Exec["install-webapp"],
  }

  file { "/opt/graphite/storage":
    owner => $packages::graphite-params::web_user,
    subscribe => Exec["install-webapp"],
    recurse => inf
  }

  package {
    [python-ldap, python-cairo, python-django, python-simplejson, libapache2-mod-wsgi, python-memcache, python-pysqlite2, python-rrdtool]:
      require => Exec['aptgetupdate'],
      ensure  => latest;
  }
}
