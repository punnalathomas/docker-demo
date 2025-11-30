# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"

  # ---------------------------
  # MASTER
  # ---------------------------
  config.vm.define "master", primary: true do |master|
    master.vm.hostname = "master"
    master.vm.network "private_network", ip: "192.168.12.10"
    master.vm.provision "shell", path: "scripts/master.sh"

    # VirtualBox Provider Settings
    # Allocate more RAM and enable performance optimizations
    master.vm.provider "virtualbox" do |vb|
      vb.memory = 2048   # master: 2 GB
      vb.cpus = 1        # master: 1 CPU

      vb.customize ["modifyvm", :id, "--ioapic", "on"]       # Enable I/O APIC for better I/O handling
      vb.customize ["modifyvm", :id, "--nestedpaging", "on"] # Enable nested paging for memory efficiency
      vb.customize ["modifyvm", :id, "--hwvirtex", "on"]     # Enforce hardware virtualization extensions
      vb.customize ["modifyvm", :id, "--pae", "on"]          # Enable Physical Address Extension   
    end
  end

  # ---------------------------
  # MINION1
  # ---------------------------
  config.vm.define "minion1" do |minion|
    minion.vm.hostname = "minion1"
    minion.vm.network "private_network", ip: "192.168.12.11"

    # Forward load balancer port on host (http://localhost:8080)
    minion.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true

    # Forward container ports on host if LB not used (http://localhost:8081)
    minion.vm.network "forwarded_port", guest: 8081, host: 8081, auto_correct: true
    minion.vm.network "forwarded_port", guest: 8082, host: 8082, auto_correct: true
    minion.vm.network "forwarded_port", guest: 8083, host: 8083, auto_correct: true

    minion.vm.provision "shell", path: "scripts/minion.sh"

    # VirtualBox Provider Settings
    # Allocate more RAM and enable performance optimizations
    minion.vm.provider "virtualbox" do |vb|
      vb.memory = 2048   # minion1: 2 GB
      vb.cpus = 1        # minion1: 1 CPU  
      
      vb.customize ["modifyvm", :id, "--ioapic", "on"]       # Enable I/O APIC for better I/O handling
      vb.customize ["modifyvm", :id, "--nestedpaging", "on"] # Enable nested paging for memory efficiency
      vb.customize ["modifyvm", :id, "--hwvirtex", "on"]     # Enforce hardware virtualization extensions
      vb.customize ["modifyvm", :id, "--pae", "on"]          # Enable Physical Address Extension 
    end
  end

end
