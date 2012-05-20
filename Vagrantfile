# You can find the box at http://hazrac.morpheus.net/lucid32-dev51512.box
#

Vagrant::Config.run do |config|

  config.vm.define :graphite do |gserver_config| 
    gserver_config.vm.host_name = "graphite"
    gserver_config.vm.box = "dev42212"
    gserver_config.vm.forward_port 22, 2024
    gserver_config.vm.provision :puppet do |puppet|
	puppet.manifest_file = "onboot.pp"
    end
    #gserver_config.vm.network :hostonly, "10.2.1.4"  # uncomment this for local networking only (for local dev)
    gserver_config.vm.network :bridged, :bridge => "eth0" # uncomment this, and comment above, to have vm on public net
  end

end
