# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Install latest version of Chef
  config.omnibus.chef_version = :latest

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "opscode-ubuntu-12.04"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-12.04_chef-provisionerless.box"

  # Override settings for specific providers
  config.vm.provider :virtualbox do |vb, override|
    vb.name = "alm"

    # Boot with a GUI so you can see the screen. (Default is headless)
    # vb.gui = true

    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.provider :vmware_fusion do |fusion, override|
    fusion.vmx["memsize"] = "1024"

    override.vm.box_url = "http://files.vagrantup.com/precise64_vmware.box"
  end

  config.vm.provider :aws do |aws, override|
    aws.access_key_id = ENV['AWS_KEY_ID']
    aws.secret_access_key = ENV['AWS_SECRET_KEY']
    aws.keypair_name = ENV['AWS_KEYPAIR_NAME']
    aws.security_groups = ENV['AWS_SECURITY_GROUP']
    aws.instance_type = "m1.small"
    aws.ami = "ami-e7582d8e"
    aws.tags = { Name: 'Vagrant alm' }

    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = ENV['AWS_KEY_PATH']
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
  end

  config.vm.provider :digital_ocean do |provider, override|
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.box = 'digital_ocean'
    override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
    override.ssh.username = "ubuntu"

    provider.region = 'nyc2'
    provider.image = 'Ubuntu 12.04.4 x64'
    provider.size = '1GB'

    # please configure
    override.vm.hostname = "ALM.EXAMPLE.ORG"
    provider.token = 'EXAMPLE'
  end

  config.vm.hostname = "alm.local"

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
  config.vm.synced_folder ".", "/vagrant", :disabled => true
  config.vm.synced_folder ".", "/var/www/alm/shared"

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  config.vm.provision :chef_solo do |chef|
    # the next line is added
    chef.custom_config_path = "Vagrantfile.chef"

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
