## !!!!06!!!!7\Vagrantfile
## This Vagrantfile builds BOTH !!!!04!!!! front-end (!!!!01!!!!) and
## back-end (!!!!02!!!!) VM server images.
# -*- mode: ruby -*-
# vi: set ft=ruby :
#
## Usage:  Navigate to the folder containing this file and...
# vagrant up --provider=vmware_workstation
#   OR vagrant up !!!!01!!!! --provider=vmware_workstation
#   OR vagrant up !!!!02!!!! --provider=vmware_workstation

## Most of what follows is per
## http://vmtrooper.com/vagrant-static-external-ip-addresses-with-the-vmware-fusion-provider/

Vagrant.configure("2") do |config|

  ## ---------------------------------------------------------------------------
  ## Define the back-end, server:  '!!!!02!!!!'

  config.vm.define :!!!!02!!!! do |!!!!02!!!!|
    !!!!02!!!!.vm.box = "phusion-open-ubuntu-14.04-amd64"
    !!!!02!!!!.vm.box_url = "https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vmwarefusion.box"
    !!!!02!!!!.vm.hostname = "!!!!02!!!!.!!!!04!!!!"

    ## Either of the following statements, when enabled, creates an eth1 adapter with an address in the bridged adapter's range.
    # !!!!02!!!!.vm.network "public_network", :bridge => 'Intel(R) 82579LM Gigabit Network Connection'
    # !!!!02!!!!.vm.network "public_network", :bridge => 'Realtek PCIe GBE Family Controller'
    ## The following statement, when enabled, creates an eth1 (*or eth2) adapter bound to my VPN with an address in the 192.168.1.x range.
    ## *Note that when both of the "public_network, :bridge" statements are enabled this second bridge binds to eth2.
    # !!!!02!!!!.vm.network "public_network", :bridge => 'Cisco Systems VPN Adapter for 64-bit Windows'

    ## Attempting this per https://github.com/mitchellh/vagrant/issues/743#issuecomment-16442405  It works!
    ## Eth1 gets a DHCP address and Eth2 gets the prescribed static IP set by bootstrap's manifests/init.pp
    !!!!02!!!!.vm.network :public_network, :bridge => 'eth1: Ethernet'
    !!!!02!!!!.vm.network :public_network, :bridge => 'eth2: Ethernet', :auto_config => false

    !!!!02!!!!.vm.provider :vmware_workstation do |v|
       v.vmx["memsize"] = "1024"
       v.vmx["numvcpus"] = "2"
    end
    config.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file = "!!!!02!!!!.pp"                  ## Attention!
      puppet.module_path = "modules"
      puppet.options = "--verbose " # --debug"
    end
    config.vm.network :forwarded_port, guest: 80, host: 8888
  end

  ## ---------------------------------------------------------------------------
  ## Define the front-end, server:  '!!!!01!!!!'

  config.vm.define :!!!!01!!!! do |!!!!01!!!!|
    !!!!01!!!!.vm.box = "phusion-open-ubuntu-14.04-amd64"
    !!!!01!!!!.vm.box_url = "https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vmwarefusion.box"
    !!!!01!!!!.vm.hostname = "!!!!01!!!!.!!!!04!!!!"

    ## Attempting this per https://github.com/mitchellh/vagrant/issues/743#issuecomment-16442405  It works!
    ## Eth1 and Eth2 both get the prescribed static IP's set in the node's puppet.mainfest_file
    !!!!01!!!!.vm.network :public_network, :bridge => 'eth1: Ethernet', :auto_config => false
    !!!!01!!!!.vm.network :public_network, :bridge => 'eth2: Ethernet', :auto_config => false

    !!!!01!!!!.vm.provider :vmware_workstation do |v|
       v.vmx["memsize"] = "1024"
       v.vmx["numvcpus"] = "2"
    end
    config.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file = "!!!!01!!!!.pp"                  ## Attention!
      puppet.module_path = "modules"
      puppet.options = "--verbose "  # --debug"
    end
    config.vm.network :forwarded_port, guest: 80, host: 8888
  end

  ## Define some DNS names

  config.landrush.enabled = true
  config.landrush.host 'repository.!!!!03!!!!', '132.161.151.25'
  config.landrush.host 'repositorytest.!!!!03!!!!', '132.161.151.28'
  config.landrush.host 'digital.!!!!03!!!!', '132.161.151.26'
  config.landrush.host '!!!!02!!!!.!!!!04!!!!', '192.168.1.100'
  config.landrush.host '!!!!01!!!!.!!!!04!!!!', '192.168.1.101'
  config.landrush.host '!!!!02!!!!.!!!!03!!!!', '132.161.151.51'
  config.landrush.host '!!!!01!!!!.!!!!03!!!!', '132.161.151.50'

end

## GC laptop network adapters are:
#
# 'Cisco Systems VPN Adapter for 64-bit Windows'         - VPN
# 'Intel(R) 82579LM Gigabit Network Connection'          - wired
# 'Broadcom 43224AG 802.11a/b/g/draft-n Wi-Fi Adapter'   - wireless
#
## Shadowfax network adapter is:
#
# 'Realtek PCIe GBE Family Controller'                   - wired

