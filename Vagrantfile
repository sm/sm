#!/usr/bin/env ruby

VAGRANTFILE_API_VERSION="2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  RAM = 512
  CPU = 2
  NETWORK="192.168.69"
  BOXES = ENV["BOXES"] ? ENV["BOXES"].to_i : 1
  ROLE = ENV["ROLE"] ? ENV["ROLE"] : "sm"

  config.vm.box = "centos64"
  config.vm.box_url = "https://github.com/2creatives/vagrant-centos/releases/download/v0.1.0/centos64-x86_64-20131030.box"

  (0..(BOXES-1)).to_a.each do |index|
    ip= 100 + index
    config.vm.define "#{ROLE}-#{index}", primary: true do |v|
      v.vm.network "private_network", ip: "#{NETWORK}.#{ip}"
      v.vm.hostname = "#{ROLE}-#{index}"

      v.vm.provision "shell",inline: %Q| yum install -y zsh openssl-devel readline-devel zlib-devel ; cd /vagrant/ ; ./install |
    end
  end

  # Provider specifics
  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", RAM]
    v.customize ["modifyvm", :id, "--cpus", CPU]
  end

  config.vm.provider "vmware_fusion" do |v, override|
    #override.vm.box = "centos64_vmware"
    v.vmx["numvcpus"] = CPU
    v.vmx["memsize"] = RAM
  end

  # Timeouts
  config.vm.graceful_halt_timeout = 300 # seconds
  config.vm.boot_timeout = 300 # seconds
end

