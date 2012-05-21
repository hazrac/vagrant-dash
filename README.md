# vagrant-dash

A Vagrant config and set of Puppet scripts to build out a Graphite Dashboard with StatsD and its dependencies.

## Overview

 This is a Vagrant config file to spin up an Ubuntu Lucid server that is running Graphite and StatsD with all the necessary dependancies. The intended use of this VM is for development purposes.  The base of the puppet manifests came from this project [Spikelab - puppet-graphite](https://github.com/spikelab/puppet-graphite) and then significant changes were made to add configurations I required.  With further improvements the Puppet modules may be able to be modified to support a production build out.

In addition the configuration installs a puppet client which could be configured for regular puppet runs.

 There are plenty of improvements that can be made (look at graphite.pp) and any controbutions are welcome.

## Configuration

First get started by installing and setting up Vagrant and Virtualbox.  More information can be found here [Vagrant - getting started](http://vagrantup.com/docs/getting-started/index.html). You'll then need to follow the Vagrant instructions to add a new box which needs the short name "dev51512", you can download the base box from here [Dev Box](http://hazrac.morpheus.net/lucid32-dev51512.box).

### The following versions of software are part of the Puppet modules
For Graphite, these can be found in: vagrant-dash/manifests/modules/packages/files/graphite/
*  carbon-0.9.9
*  graphite-web-0.9.9
*  whisper-0.9.9

For StatsD, this can be found in: vagrant-dash/manifests/modules/packages/files/statsd/statsd/
*  statsd-0.2.1
*  NodeJS


### Once complete there are a few files you should consider editing:

The following file should be renamed to *authorized_keys* and you should include your public SSH key in the file.

*vagrant-dash/manifests/files/pub_keys/EXAMPLE.authorized_keys*

The below manifest for users can be edited to include your own username and password

*vagrant-dash/manifests/modules/users/manifests/init.pp*

## Known Issues
Normally this Vagrant config has quite a few VMs, I've slimmed it down to this one as it was the most useful.  Since moving it from a private repo to a public one a few things have broken, which I intent to fix shortly.  Notably:
*  The /opt/graphite/storage/graphite.db file will at times come up with the wrong permissions (root:root vs. www-data:www-data)
*  The initial boot time, with puppet runs, is close to 20 minutes! (it was near 3)

If you insist on using this before I fix these problems you can start the VM and then go to the VM's IP in your web browser, which will bring up the graphite dashboard.  If you click on a broken graph it will tell you what the issue is.

## TODO

*  Need to cleanup graphite.pp and clean-up the dependancies in that file
*  Place packages within the modules so that network connectivity isn't needed
  *  Create a script to update those packages on the host machine if wanted
*  Add Gdash to the install
*  Add Tasseo as well
*  Lots more


