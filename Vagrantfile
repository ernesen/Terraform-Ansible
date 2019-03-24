# http://sysadm.pp.ua/linux/sistemy-virtualizacii/vagrantfile.html

# -*- mode: ruby -*-
# vi: set ft=ruby :
# Use config.yaml for basic VM configuration.

require 'yaml'
dir = File.dirname(File.expand_path(__FILE__))
config_nodes = "#{dir}/artifacts/config/config_multi-nodes.yaml"

if !File.exist?("#{config_nodes}")
  raise 'Configuration file is missing! Please make sure that the configuration exists and try again.'
end
vconfig = YAML::load_file("#{config_nodes}")

BRIDGE_NET = vconfig['vagrant_ip']
DOMAIN = vconfig['vagrant_domain_name']
RAM = vconfig['vagrant_memory']

servers=[
  {
    :hostname => "software." + "#{DOMAIN}",
    :ip => "#{BRIDGE_NET}" + "160",
    :ram => "#{RAM}",
	:install_software => "./artifacts/scripts/install_software.sh", 
	:config_software => "./artifacts/scripts/config_software.sh",
	:source =>  "./artifacts/.",
	:destination => "/home/vagrant/"
  }
]
 
Vagrant.configure(2) do |config|
    config.vm.synced_folder ".", vconfig['vagrant_directory'], :mount_options => ["dmode=777", "fmode=666"]
    servers.each do |machine|
        config.vm.define machine[:hostname] do |node|
			node.vm.box = vconfig['vagrant_box']
			node.vm.box_version = vconfig['vagrant_box_version']
			node.vm.hostname = machine[:hostname]
            node.vm.network "private_network", ip: machine[:ip] 
            node.vm.provider "virtualbox" do |vb|
                vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
				vb.cpus = vconfig['vagrant_cpu']
				vb.memory = machine[:ram]
                vb.name = machine[:hostname]
                if (!machine[:install_software].nil?)
                  if File.exist?(machine[:install_software])
					node.vm.provision :shell, path: machine[:install_software]
                  end
                  if File.exist?(machine[:config_software])
					node.vm.provision :file, source: machine[:source] , destination: machine[:destination]
      			    node.vm.provision :shell, privileged: false, path: machine[:config_software]
                  end
                end
            end
        end
    end
end
