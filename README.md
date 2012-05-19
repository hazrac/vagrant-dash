# vagrant-dash

A Vagrant config and set of Puppet scripts to build out a Graphite Dashboard with StatsD and its dependencies.

## Overview

This is a Vagrant config file to spin up an Ubuntu Lucid server that is running Graphite and StatsD with all the necessary dependancies. The intended use of this VM is for development purposes.  With improvements the Puppet modules may be able to be modified to support a production build out.

In addition the configuration installs a puppet client which could be configured for regular puppet runs.

 There are plenty of improvements that can be made (look at graphite.pp) and any controbutions are welcome.

## Configuration

First get started by installing and setting up Vagrant and Virtualbox.  More information can be found here <http://vagrantup.com/docs/getting-started/index.html>. You'll then need to follow the Vagrant instructions to add a new box which needs the short name "dev51512", you can download the base box from here <http://hazrac.morpheus.net/lucid32-dev51512.box>.

### The following versions of software are part of the Puppet modules
For Graphite, these can be found in: vagrant-dash/manifests/modules/packages/files/graphite/
carbon-0.9.9
graphite-web-0.9.9
whisper-0.9.9

For StatsD, this can be found in: vagrant-dash/manifests/modules/packages/files/statsd/statsd/
statsd-0.2.1


### Once complete there are a few files you should consider editing:

The following file should be renamed to 'authorized_keys' and you should include your public SSH key in the file.
vagrant-dash/manifests/files/pub_keys/EXAMPLE.authorized_keys

The below manifest for users can be edited to include your own username and password
vagrant-dash/manifests/modules/users/manifests/init.pp

## TODO

-Need to cleanup graphite.pp and clean-up the dependancies in that file
-Add Gdash to the install
-Add Tasseo as well
-Lots more


