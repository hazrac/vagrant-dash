# Basic Puppet manifest

include users
include users::groups

include packages::puppet-client

# If you wanted to add multiple hosts we would just want graphite and statsd on the graphite server
if $hostname == 'graphite' {
  include packages::graphite
  include packages::statsd
}

# These are for everybody
file {'/root/.ssh':
  ensure => directory,
  owner  => root,
  mode   => '0600',
}
# Need to replace this with your own key file
file { '/root/.ssh/authorized_keys':
  ensure => present,
  owner  => root,
  mode   => '0600',
  source => '/vagrant/manifests/files/pub_keys/authorized_keys',
}

# Set your own timezone
file { '/etc/localtime':
  ensure => link,
  target => '/usr/share/zoneinfo/US/Eastern',
}

# If you are running a much newer version of VirtualBox you may need to update the guest additions.  Uncomment the lines below and this should be done automatically for you. You need to put the guest additions ISO in vagrant-dash/manifests/files/Vboxadditions.
# If you don't want to do this every time you spin up the node you should create a new box file, instructions on how to do that are here: http://vagrantup.com/docs/base_boxes.html

# Ensure that Vbox has the most up-to-date Guest Additions 
#file {'/media/cdrom':
#  ensure => directory,
#  owner  => root,
#  mode   => '0555',
#}
#
#exec { 'mount':
#  command => 'mount -o loop /vagrant/manifests/files/Vboxadditions/VBoxGuestAdditions.iso /media/cdrom',
#  path    => '/bin/',
#}
#
#package { 'linux-headers-2.6.32-33-generic':
#  ensure => present,
#}

#exec { 'install_additions':
#  command => 'sudo /media/cdrom/VBoxLinuxAdditions.run --nox11',
#  path    => '/usr/bin/',
#}

#File['/media/cdrom'] -> Exec['mount'] -> Package['linux-headers-2.6.32-33-generic'] -> Exec['install_additions']


