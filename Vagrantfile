Vagrant.configure("2") do |config|
  # on hyperv, we need a special plugin
  config.vm.provider "hyperv" do |hyperv, override|
    override.trigger.before :up do |trigger|
      trigger.info = "Ensuring we have vagrant-reload for Hyper-V"
      trigger.ruby do ||
        if !Vagrant.has_plugin?("vagrant-reload")
          puts "The #{plugin} plugin is required. Please install it with:"
          puts "$ vagrant plugin install #{plugin}"
          exit
        end
      end
    end
  end

  # for hyperv support, we need to create a custom switch to use
  config.vm.provider "hyperv" do |hyperv, override|
    override.trigger.before :up do |trigger|
        trigger.info = "Creating 'CBDCSwitch' Hyper-V switch if it does not exist..."
        trigger.run = {privileged: "true", powershell_elevated_interactive: "true", path: "./scripts/hyperv-create-nat-switch.ps1"}
    end
  end

  # basic vm configuration
  config.vm.box = "generic/ubuntu2004"
  config.vm.hostname = "dyncluster"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "3072"
  end
  config.vm.provider "hyperv" do |hyperv|
    hyperv.maxmemory = "3072"
  end

  # set up initial networking
  config.vm.provider "virtualbox" do |vb, override|
    override.vm.network :private_network, ip: "192.168.99.5", :netmask => "255.255.255.0"
  end
  config.vm.provider "hyperv" do |hyperv, override|
    override.vm.network :private_network, bridge: "CBDCSwitch"
  end

  # disable folder sync since we don't use it and it causes prompts on hyperv
  config.vm.synced_folder '.', '/vagrant', disabled: true

  # on virtualbox, we just run the setup script
  config.vm.provider "virtualbox" do |vb, override|
    override.vm.provision "shell", path: "./scripts/setup-vm.sh"
  end

  # on hyperv, we need to do some special things first
  config.vm.provider "hyperv" do |hyperv, override|
    # we need to enable mac address spoofing
    hyperv.vmname = "dyncluster"
    override.trigger.after :up, type: :action do |trigger|
      trigger.info = "Enabling MAC Address Spoofing on Hyper-V VM"
      trigger.run = { privileged: "true", powershell_elevated_interactive: "true", inline: "Set-VMNetworkAdapter -VMName dyncluster -MacAddressSpoofing On" }
    end

    # we need to manually set up the ip address first
    override.vm.provision "shell", inline: <<-SHELL
      ip address
    SHELL

    override.vm.provision "shell", path: "./scripts/hyperv-configure-static-ip.sh"
    override.vm.provision :reload

    override.vm.provision "shell", inline: <<-SHELL
      ip address
    SHELL
   
    # now we can run setup...
    override.vm.provision "shell", path: "./scripts/setup-vm.sh"
  end

end
