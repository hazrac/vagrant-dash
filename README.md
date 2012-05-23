# vagrant-dash

A Vagrant config and set of Puppet scripts to build out a Graphite Dashboard with StatsD and its dependencies.

## Overview

 This is a Vagrant config file to spin up an Ubuntu Lucid server that is running Graphite and StatsD with all the necessary dependancies. The intended use of this VM is for development purposes.  The base of the puppet manifests came from this project [Spikelab - puppet-graphite](https://github.com/spikelab/puppet-graphite) and then significant changes were made to add configurations I required.  With further improvements the Puppet modules may be able to be modified to support a production build out.

In addition the configuration installs a puppet client which could be configured for regular puppet runs.

 There are plenty of improvements that can be made and any contributions are welcome.

## Configuration

First get started by installing and setting up Vagrant and Virtualbox.  More information can be found here [Vagrant - getting started](http://vagrantup.com/docs/getting-started/index.html). You'll then need to follow the Vagrant instructions to add a new box which needs the short name "dev51512", you can download the base box from here [Dev Box](http://hazrac.morpheus.net/lucid32-dev51512.box).

### The following versions of software are part of the Puppet modules
For StatsD, this can be found in: vagrant-dash/modules/packages/files/statsd/statsd/
*  statsd-0.2.1
*  NodeJS

### These software packages are downloaded at the time of the puppet run
*  carbon-0.9.9
*  graphite-web-0.9.9
*  whisper-0.9.9


### Once complete there are a few files you should consider editing:

The following file should be renamed to *authorized_keys* and you should include your public SSH key in the file.

*vagrant-dash/manifests/files/pub_keys/EXAMPLE.authorized_keys*

The below manifest for users can be edited to include your own username and password

*vagrant-dash/modules/users/manifests/init.pp*

## Known Issues
Normally this Vagrant config has quite a few VMs, I've slimmed it down to this one as it was the most useful.  Since moving it from a private repo to a public one a few things have broken, which I intent to fix shortly.  Notably:
*  The Apache config isn't correct
*  Carbon doesn't start due to the timing in the puppet script

If you insist on using this before I fix these problems you can make adjustments to the vhost config for Apache and manually start carbon with the init script provided in /etc/init.d.

## TODO

*  Place packages within the modules so that network connectivity isn't needed
  *  Create a script to update those packages on the host machine if wanted
*  Add Gdash to the install
*  Add Tasseo as well
*  Take Graphite manifests out of the packages module and create its own module

## Contact

David Mitchell / dmitchell@hazrac.org / http://www.hazrac.org / @hazrac
