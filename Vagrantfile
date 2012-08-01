# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "lucid32"
  # config.vm.box = "centos-57-x86_64box"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/lucid32.box"

  # Boot with a GUI so you can see the screen. (Default is headless)
  #config.vm.boot_mode = :gui

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.


  # Assign this VM to a bridged network, allowing you to connect directly to a
  # network using the host's network device. This makes the VM appear as another
  # physical device on your network.
  # config.vm.network :bridged
  
  # Workaround for Vagrant bug
  config.ssh.max_tries = 150

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  config.vm.forward_port 80, 8080
  config.vm.forward_port 3000, 3000
  config.vm.forward_port 5984, 5984

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  # config.vm.share_folder "v-data", "/vagrant_data", "../data"

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding 
  # some recipes and/or roles.
  #
  config.vm.provision :chef_solo do |chef|	
    # Turn on verbose Chef logging if necessary
    chef.log_level = :info
    
    # Update system
    chef.add_recipe "apt"
    chef.add_recipe "build-essential"
    chef.add_recipe "git"

    # Install rvm and Ruby 1.9.3. Add Chef Solo path
    chef.add_recipe "rvm::system"
    chef.add_recipe "rvm::vagrant"
    
    # Load recipe specific for this application
    chef.add_recipe "alm"
    
    # Add application-specific attributes:
    chef.json.merge!({ 
      :app => { :layout => "greenrobo", :seed_additional_sources => true, :seed_sample_articles => true, 
                :mendeley => { :api_key => "EXAMPLE"},
                :facebook => { :api_key => "EXAMPLE"},
                :crossref=> { :username => "EXAMPLE", :password => "EXAMPLE"},
                :researchblogging => { :username => "EXAMPLE", :password => "EXAMPLE"},
                :nature => { :api_key => "EXAMPLE"}},
      :rvm => { :global_gems => [{ 'name' => 'bundler', 'version' => '1.1.5' }, 
                                 { 'name' => 'rake', 'version' => '0.9.2.2'},
                                 { 'name' => 'chef', 'version' => '10.12.0' },
                                 { 'name' => 'passenger', 'version' => '3.0.14'}]},
      :rails => { :environment => "development" },
      :passenger => { :version => "3.0.14" },
      :admin => { :email => "ADMIN@EXAMPLE.ORG" },
      :mysql => { :bind_address => "0.0.0.0", :tunable => { :innodb_buffer_pool_size => "512M" } },
      :couchdb => { :src_version => "1.1.0", :bind_address => "0.0.0.0", :db_name => "alm" }
    })
    
  end
end