# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"

  # ---------------------------
  # MASTER
  # ---------------------------
  config.vm.define "master", primary: true do |master|
    master.vm.hostname = "master"
    master.vm.network "private_network", ip: "192.168.12.3"
    master.vm.provision "shell", path: "scripts/master.sh"

    # Add 2 GB RAM
    master.vm.provider "virtualbox" do |vb|
      vb.memory = 2048   # master: 2 GB
      vb.cpus = 2        # master: 2 CPU
    end
  end

  # ---------------------------
  # MINION1
  # ---------------------------
  config.vm.define "minion1" do |minion|
    minion.vm.hostname = "minion1"
    minion.vm.network "private_network", ip: "192.168.12.100"
    minion.vm.provision "shell", path: "scripts/minion.sh"

    # Add 1 GB RAM
    minion.vm.provider "virtualbox" do |vb|
      vb.memory = 1024   # minion1: 1 GB
      vb.cpus = 1        # minion1: 1 CPU   
    end
  end

  # ---------------------------
  # MINION2
  # ---------------------------
  config.vm.define "minion2" do |minion|
    minion.vm.hostname = "minion2"
    minion.vm.network "private_network", ip: "192.168.12.101"
    minion.vm.provision "shell", path: "scripts/minion.sh"

    # Add 1 GB RAM
    minion.vm.provider "virtualbox" do |vb|
      vb.memory = 1024   # minion2: 1 GB
      vb.cpus = 1        # minion2: 1 CPU
    end
  end

end
