# -*- mode: ruby -*-
# vi: set ft=ruby :

# Enable provisioning with chef solo, specifying a cookbooks path, roles
# path, and data_bags path (all relative to this Vagrantfile), and adding
# some recipes and/or roles.
def provision(config, override, overrides = {})
  override.vm.provision :chef_solo do |chef|
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

    chef.json['alm'].merge!(overrides['alm'] || {})
  end

  # Link database.yml and settings.yml generated in alm recipe to current app directory
  # and install required gems and run pending database migrations
  override.vm.provision "shell", inline: <<-EOF
    ln -fs /var/www/alm/shared/config/database.yml /var/www/alm/current/config/database.yml
    ln -fs /var/www/alm/shared/config/settings.yml /var/www/alm/current/config/settings.yml
    cd /var/www/alm/current && bundle && bundle exec rake db:migrate
  EOF
end

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Check if required plugins are installed.
  unless Vagrant.has_plugin?('vagrant-omnibus')
    puts "vagrant-omnibus plugin is missing. Installing..."
    %x(set -x; vagrant plugin install vagrant-omnibus)
    restart = true
  end

  unless Vagrant.has_plugin?('vagrant-librarian-chef')
    puts "vagrant-librarian-chef plugin is missing. Installing..."
    %x(set -x; vagrant plugin install vagrant-librarian-chef )
    restart = true
  end

  unless Vagrant.has_plugin?('vagrant-bindfs')
    puts "vagrant-bindfs plugin is missing. Installing..."
    %x(set -x; vagrant plugin install vagrant-bindfs )
    restart = true
  end

  if restart
    puts "Plugins have now been installed, please rerun vagrant."
    exit
  end

  # Install latest version of Chef
  config.omnibus.chef_version = :latest

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "chef/ubuntu-14.04"

  # For any additional, provider-specific overrides for provisioning
  chef_overrides = {}

  # Override settings for specific providers
  config.vm.provider :virtualbox do |vb, override|
    vb.name = "alm"
    vb.customize ["modifyvm", :id, "--memory", "1024"]
    nfs_setting = RUBY_PLATFORM =~ /darwin/ || RUBY_PLATFORM =~ /linux/
    # Disable default synced folder before bindfs tries to bind to it
    override.vm.synced_folder ".", "/var/www/alm-report/current", disabled: true
    override.vm.synced_folder ".", "/vagrant", id: "vagrant-root", :nfs => nfs_setting
    override.bindfs.bind_folder "/vagrant", "/var/www/alm-report/current"

    provision(vb, override)
  end

  config.vm.provider :vmware_fusion do |fusion, override|
    fusion.vmx["memsize"] = "1024"
    provision(config, override)
  end

  config.vm.provider :aws do |aws, override|
    aws.access_key_id = "EXAMPLE"
    aws.secret_access_key = "EXAMPLE"
    aws.keypair_name = "EXAMPLE"
    aws.security_groups = ["EXAMPLE"]
    aws.instance_type = "m3.medium"
    aws.ami = "ami-0307d674"
    aws.region = "eu-west-1"
    aws.tags = { Name: 'Vagrant ALM' }
    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = "~/path/to/ec2/key.pem"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

    # Custom parameters for the ALM recipe
    chef_overrides['alm'] = {
      'user' => 'ubuntu',
      'group' => 'ubuntu',
      'provider' => 'aws'
    }

    provision(config, override, chef_overrides)
  end

  config.vm.provider :digital_ocean do |provider, override|
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.box = 'digital_ocean'
    override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
    override.ssh.username = "ubuntu"

    provider.region = 'nyc2'
    provider.image = 'Ubuntu 14.04 x64'
    provider.size = '1GB'

    # please configure
    override.vm.hostname = "ALM.EXAMPLE.ORG"
    provider.token = 'EXAMPLE'

    provision(config, override, chef_overrides)
  end

  config.vm.hostname = "alm.local"
  # Boot with a GUI so you can see the screen. (Default is headless)
  # config.vm.boot_mode = :gui

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  config.vm.network :private_network, ip: "10.2.2.4"

  # Assign this VM to a bridged network, allowing you to connect directly to a
  # network using the host's network device. This makes the VM appear as another
  # physical device on your network.
  # config.vm.network :bridged

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  config.vm.network :forwarded_port, guest: 80, host: 8080 # Apache2

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.

  config.vm.synced_folder ".", "/var/www/alm/current", id: "vagrant-root"
end
