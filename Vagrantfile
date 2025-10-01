# -*- mode: ruby -*-
# vi: set ft=ruby :
# Generated Vagrantfile for Burst-A-Flat
# Provider: virtualbox
# Generated on: Mon Sep 29 10:49:05 AM CDT 2025

Vagrant.configure("2") do |config|
  # Global configuration
  config.vm.box = "ubuntu/jammy64"
  config.vm.box_check_update = false
  
  # Network configuration - no global networks, each VM defines its own
  
  # Provider configuration
  config.vm.provider "virtualbox" do |provider|
    provider.name = "login-node"
    provider.memory = "1024"
    provider.cpus = 2
    provider.gui = false
  end

  # login-node - 
  config.vm.define "login-node" do |login_node|
    login_node.vm.hostname = "login-node"
    login_node.vm.network "private_network", ip: "192.168.50.10", virtualbox__intnet: "onprem-network"
    # Add NAT for internet access
    login_node.vm.network "private_network", type: "nat"
    # Copy SSH public key from host to VM
    login_node.vm.provision "file", source: "~/.ssh/id_ed25519.pub", destination: "/tmp/host_key.pub"
    login_node.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add host SSH key if it exists
      if [ -f /tmp/host_key.pub ]; then
        if ! grep -q "$(cat /tmp/host_key.pub)" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
          cat /tmp/host_key.pub >> /home/vagrant/.ssh/authorized_keys
        fi
        rm /tmp/host_key.pub
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    login_node.vm.provider "virtualbox" do |provider|
      provider.name = "login-node"
      provider.memory = "1024"
      provider.cpus = 2
    end
  end

  # management-node - 
  config.vm.define "management-node" do |management_node|
    management_node.vm.hostname = "management-node"
    management_node.vm.network "private_network", ip: "192.168.50.11", virtualbox__hostonly: "network1"
    # Copy SSH public key from host to VM
    management_node.vm.provision "file", source: "~/.ssh/id_ed25519.pub", destination: "/tmp/host_key.pub"
    management_node.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add host SSH key if it exists
      if [ -f /tmp/host_key.pub ]; then
        if ! grep -q "$(cat /tmp/host_key.pub)" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
          cat /tmp/host_key.pub >> /home/vagrant/.ssh/authorized_keys
        fi
        rm /tmp/host_key.pub
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    management_node.vm.provider "virtualbox" do |provider|
      provider.name = "management-node"
      provider.memory = "1024"
      provider.cpus = 2
    end
  end

  # controller-node - 
  config.vm.define "controller-node" do |controller_node|
    controller_node.vm.hostname = "controller-node"
    controller_node.vm.network "private_network", ip: "192.168.50.12", virtualbox__hostonly: "network1"
    # Add NAT for internet access (controller acts as gateway)
    controller_node.vm.network "private_network", type: "nat"
    # Copy SSH public key from host to VM
    controller_node.vm.provision "file", source: "~/.ssh/id_ed25519.pub", destination: "/tmp/host_key.pub"
    controller_node.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add host SSH key if it exists
      if [ -f /tmp/host_key.pub ]; then
        if ! grep -q "$(cat /tmp/host_key.pub)" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
          cat /tmp/host_key.pub >> /home/vagrant/.ssh/authorized_keys
        fi
        rm /tmp/host_key.pub
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    controller_node.vm.provider "virtualbox" do |provider|
      provider.name = "controller-node"
      provider.memory = "2048"
      provider.cpus = 4
    end
  end

  # slurmdb-node - 
  config.vm.define "slurmdb-node" do |slurmdb_node|
    slurmdb_node.vm.hostname = "slurmdb-node"
    slurmdb_node.vm.network "private_network", ip: "192.168.50.13", virtualbox__hostonly: "network1"
    # Copy SSH public key from host to VM
    slurmdb_node.vm.provision "file", source: "~/.ssh/id_ed25519.pub", destination: "/tmp/host_key.pub"
    slurmdb_node.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add host SSH key if it exists
      if [ -f /tmp/host_key.pub ]; then
        if ! grep -q "$(cat /tmp/host_key.pub)" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
          cat /tmp/host_key.pub >> /home/vagrant/.ssh/authorized_keys
        fi
        rm /tmp/host_key.pub
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    slurmdb_node.vm.provider "virtualbox" do |provider|
      provider.name = "slurmdb-node"
      provider.memory = "1024"
      provider.cpus = 2
    end
  end

  # compute-node-1 - 
  config.vm.define "compute-node-1" do |compute_node_1|
    compute_node_1.vm.hostname = "compute-node-1"
    compute_node_1.vm.network "private_network", ip: "192.168.50.14", virtualbox__hostonly: "network1"
    # Copy SSH public key from host to VM
    compute_node_1.vm.provision "file", source: "~/.ssh/id_ed25519.pub", destination: "/tmp/host_key.pub"
    compute_node_1.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add host SSH key if it exists
      if [ -f /tmp/host_key.pub ]; then
        if ! grep -q "$(cat /tmp/host_key.pub)" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
          cat /tmp/host_key.pub >> /home/vagrant/.ssh/authorized_keys
        fi
        rm /tmp/host_key.pub
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    compute_node_1.vm.provider "virtualbox" do |provider|
      provider.name = "compute-node-1"
      provider.memory = "2048"
      provider.cpus = 4
    end
  end

  # compute-node-2 - 
  config.vm.define "compute-node-2" do |compute_node_2|
    compute_node_2.vm.hostname = "compute-node-2"
    compute_node_2.vm.network "private_network", ip: "192.168.50.15", virtualbox__hostonly: "network1"
    # Copy SSH public key from host to VM
    compute_node_2.vm.provision "file", source: "~/.ssh/id_ed25519.pub", destination: "/tmp/host_key.pub"
    compute_node_2.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add host SSH key if it exists
      if [ -f /tmp/host_key.pub ]; then
        if ! grep -q "$(cat /tmp/host_key.pub)" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
          cat /tmp/host_key.pub >> /home/vagrant/.ssh/authorized_keys
        fi
        rm /tmp/host_key.pub
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    compute_node_2.vm.provider "virtualbox" do |provider|
      provider.name = "compute-node-2"
      provider.memory = "2048"
      provider.cpus = 4
    end
  end

  # nosql-node-1 - 
  config.vm.define "nosql-node-1" do |nosql_node_1|
    nosql_node_1.vm.hostname = "nosql-node-1"
    nosql_node_1.vm.network "private_network", ip: "192.168.50.16", virtualbox__hostonly: "network1"
    # Copy SSH public key from host to VM
    nosql_node_1.vm.provision "file", source: "~/.ssh/id_ed25519.pub", destination: "/tmp/host_key.pub"
    nosql_node_1.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add host SSH key if it exists
      if [ -f /tmp/host_key.pub ]; then
        if ! grep -q "$(cat /tmp/host_key.pub)" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
          cat /tmp/host_key.pub >> /home/vagrant/.ssh/authorized_keys
        fi
        rm /tmp/host_key.pub
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    nosql_node_1.vm.provider "virtualbox" do |provider|
      provider.name = "nosql-node-1"
      provider.memory = "1024"
      provider.cpus = 2
    end
  end

  # compute-node-3 - 
  config.vm.define "compute-node-3" do |compute_node_3|
    compute_node_3.vm.hostname = "compute-node-3"
    compute_node_3.vm.network "private_network", ip: "192.168.60.10", virtualbox__hostonly: "network2"
    # Copy SSH public key from host to VM
    compute_node_3.vm.provision "file", source: "~/.ssh/id_ed25519.pub", destination: "/tmp/host_key.pub"
    compute_node_3.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add host SSH key if it exists
      if [ -f /tmp/host_key.pub ]; then
        if ! grep -q "$(cat /tmp/host_key.pub)" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
          cat /tmp/host_key.pub >> /home/vagrant/.ssh/authorized_keys
        fi
        rm /tmp/host_key.pub
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    compute_node_3.vm.provider "virtualbox" do |provider|
      provider.name = "compute-node-3"
      provider.memory = "2048"
      provider.cpus = 4
    end
  end

  # compute-node-4 - 
  config.vm.define "compute-node-4" do |compute_node_4|
    compute_node_4.vm.hostname = "compute-node-4"
    compute_node_4.vm.network "private_network", ip: "192.168.60.11", virtualbox__hostonly: "network2"
    # Copy SSH public key from host to VM
    compute_node_4.vm.provision "file", source: "~/.ssh/id_ed25519.pub", destination: "/tmp/host_key.pub"
    compute_node_4.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add host SSH key if it exists
      if [ -f /tmp/host_key.pub ]; then
        if ! grep -q "$(cat /tmp/host_key.pub)" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
          cat /tmp/host_key.pub >> /home/vagrant/.ssh/authorized_keys
        fi
        rm /tmp/host_key.pub
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    compute_node_4.vm.provider "virtualbox" do |provider|
      provider.name = "compute-node-4"
      provider.memory = "2048"
      provider.cpus = 4
    end
  end

  # nosql-node-2 - 
  config.vm.define "nosql-node-2" do |nosql_node_2|
    nosql_node_2.vm.hostname = "nosql-node-2"
    nosql_node_2.vm.network "private_network", ip: "192.168.60.12", virtualbox__hostonly: "network2"
    # Copy SSH public key from host to VM
    nosql_node_2.vm.provision "file", source: "~/.ssh/id_ed25519.pub", destination: "/tmp/host_key.pub"
    nosql_node_2.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add host SSH key if it exists
      if [ -f /tmp/host_key.pub ]; then
        if ! grep -q "$(cat /tmp/host_key.pub)" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
          cat /tmp/host_key.pub >> /home/vagrant/.ssh/authorized_keys
        fi
        rm /tmp/host_key.pub
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    nosql_node_2.vm.provider "virtualbox" do |provider|
      provider.name = "nosql-node-2"
      provider.memory = "1024"
      provider.cpus = 2
    end
  end

  # Note: Ansible provisioning is run manually after all VMs are up
  # Run: ansible-playbook -i inventory/hosts playbooks/site.yml
end
