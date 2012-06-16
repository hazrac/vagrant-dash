class packages::puppetclient {

 include packages::aptget

 package { 'facter':
   ensure  => present,
   require => Exec['aptgetupdate'],
  }

 package { 'puppet':
   #ensure  => '2.7.13-1puppetlabs1',
   #ensure  => '2.7.1',
   ensure  => latest,
   require => Exec['aptgetupdate'],
  }

 file { '/etc/init.d/puppetd':
   ensure => link,
   target => '/usr/sbin/puppetd',
   require => Package['puppet'],
 }

  service { 'puppetd':
   ensure    => running,
   enable    => true,
   subscribe => File['puppet.conf'],
   require   => File['/etc/init.d/puppetd'],
  }

  file { 'puppet.conf' :
   path    => '/etc/puppet/puppet.conf',
   ensure  => file,
   require => Package['puppet'],
   source  => 'puppet:///modules/packages/puppet/puppet-client.conf',
  }

  file { 'default_puppet' :
   path => '/etc/default/puppet',
   ensure => file,
   require => Package['puppet'],
   source => 'puppet:///modules/packages/puppet/etc_default_puppet',
  }

  file { 'puppet_key_dir':
    path    => '/var/lib/puppet/ssl',
    ensure  => directory,
    owner   => puppet,
    group   => puppet,
    source  => "puppet:///modules/packages/puppet/ssl-$::hostname",
    recurse => true,
    ignore  => '.svn',
    purge => true,
  }

}
