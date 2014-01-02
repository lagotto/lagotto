# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Install latest version of Chef
  config.omnibus.chef_version = :latest

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "precise64"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # Override settings for specific providers
  config.vm.provider :virtualbox do |vb, override|
    vb.name = "alm"
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  config.vm.provider :vmware_fusion do |fusion, override|
    fusion.vmx["memsize"] = "1024"

    override.vm.box_url = "http://files.vagrantup.com/precise64_vmware.box"
  end

  config.vm.provider :aws do |aws, override|
    aws.access_key_id = "EXAMPLE"
    aws.secret_access_key = "EXAMPLE"
    aws.keypair_name = "EXAMPLE"
    aws.security_groups = ["EXAMPLE"]
    aws.instance_type = "m1.small"
    aws.ami = "ami-e7582d8e"
    aws.tags = { Name: 'Vagrant alm' }

    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = "EXAMPLE"
  end

  config.vm.hostname = "alm"

  # Boot with a GUI so you can see the screen. (Default is headless)
  # config.vm.boot_mode = :gui

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  config.vm.network :private_network, ip: "33.33.33.44"

  # Assign this VM to a bridged network, allowing you to connect directly to a
  # network using the host's network device. This makes the VM appear as another
  # physical device on your network.
  # config.vm.network :bridged

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  config.vm.network :forwarded_port, guest: 80, host: 8080 # Apache2
  config.vm.network :forwarded_port, guest: 5984, host: 9000 # CouchDB

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  # config.vm.share_folder "v-data", "/vagrant_data", "../data"

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "vendor/cookbooks"
    dna = JSON.parse(File.read("node.json"))
    dna.delete("run_list").each do |recipe|
      chef.add_recipe(recipe)
    end
    chef.json.merge!(dna)

    # Read in user-specific configuration settings, not under version control
    if File.file?("config.json")
      config = JSON.parse(File.read("config.json"))
      chef.json.merge!(config)
    end
  end
end
