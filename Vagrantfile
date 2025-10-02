# -*- mode: ruby -*-
# vi: set ft=ruby :
# Generated Vagrantfile for Burst-A-Flat
# Provider: kvm
# Generated on: Wed Oct  1 07:23:55 PM CDT 2025

Vagrant.configure("2") do |config|
  # Global configuration
  config.vm.box = "generic/ubuntu2204"
  config.vm.box_check_update = false
  
  # Network configuration - removed global config to avoid conflicts
  
  # Provider configuration
  # KVM/libvirt global configuration
  config.vm.provider "libvirt" do |libvirt|
    libvirt.memory = "1024"
    libvirt.cpus = 2
    libvirt.graphics_type = "none"
    libvirt.video_type = "qxl"
    # Suppress fog warnings
    libvirt.uri = "qemu:///system"
  end
  # login-node - 
  config.vm.define "login-node" do |login_node|
    login_node.vm.hostname = "login-node"
    login_node.vm.network "private_network", ip: "192.168.50.10", libvirt__network_name: "onprem-network"
    login_node.vm.network "private_network", ip: "192.168.60.11", libvirt__network_name: "cloud-network"
    login_node.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add user's SSH key if not already present
      if ! grep -q "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
        echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" >> /home/vagrant/.ssh/authorized_keys
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    login_node.vm.provider "libvirt" do |provider|
      # KVM/libvirt specific options
      provider.memory = "1024"
      provider.cpus = 2
      provider.graphics_type = "none"
      provider.video_type = "qxl"
    end
  end

  # management-node - 
  config.vm.define "management-node" do |management_node|
    management_node.vm.hostname = "management-node"
    management_node.vm.network "private_network", ip: "192.168.50.11", libvirt__network_name: "onprem-network"
    management_node.vm.network "private_network", ip: "192.168.60.11", libvirt__network_name: "cloud-network"
    management_node.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add user's SSH key if not already present
      if ! grep -q "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
        echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" >> /home/vagrant/.ssh/authorized_keys
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    management_node.vm.provider "libvirt" do |provider|
      # KVM/libvirt specific options
      provider.memory = "1024"
      provider.cpus = 2
      provider.graphics_type = "none"
      provider.video_type = "qxl"
    end
  end

  # controller-node - 
  config.vm.define "controller-node" do |controller_node|
    controller_node.vm.hostname = "controller-node"
    controller_node.vm.network "private_network", ip: "192.168.50.12", libvirt__network_name: "onprem-network"
    controller_node.vm.network "private_network", ip: "192.168.60.10", libvirt__network_name: "cloud-network"
    controller_node.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add user's SSH key if not already present
      if ! grep -q "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
        echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" >> /home/vagrant/.ssh/authorized_keys
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    # Add NAT for internet access (controller acts as gateway)
    controller_node.vm.network "private_network", type: "nat", ip: "10.0.2.10"
    controller_node.vm.provider "libvirt" do |provider|
      # KVM/libvirt specific options
      provider.memory = "2048"
      provider.cpus = 4
      provider.graphics_type = "none"
      provider.video_type = "qxl"
    end
  end

  # slurmdb-node - 
  config.vm.define "slurmdb-node" do |slurmdb_node|
    slurmdb_node.vm.hostname = "slurmdb-node"
    slurmdb_node.vm.network "private_network", ip: "192.168.50.13", libvirt__network_name: "onprem-network"
    slurmdb_node.vm.network "private_network", ip: "192.168.60.10", libvirt__network_name: "cloud-network"
    slurmdb_node.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add user's SSH key if not already present
      if ! grep -q "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
        echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" >> /home/vagrant/.ssh/authorized_keys
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    slurmdb_node.vm.provider "libvirt" do |provider|
      # KVM/libvirt specific options
      provider.memory = "1024"
      provider.cpus = 2
      provider.graphics_type = "none"
      provider.video_type = "qxl"
    end
  end

  # compute-node-1 - 
  config.vm.define "compute-node-1" do |compute_node_1|
    compute_node_1.vm.hostname = "compute-node-1"
    compute_node_1.vm.network "private_network", ip: "192.168.50.14", libvirt__network_name: "onprem-network"
    compute_node_1.vm.network "private_network", ip: "192.168.60.10", libvirt__network_name: "cloud-network"
    compute_node_1.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add user's SSH key if not already present
      if ! grep -q "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
        echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" >> /home/vagrant/.ssh/authorized_keys
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    compute_node_1.vm.provider "libvirt" do |provider|
      # KVM/libvirt specific options
      provider.memory = "2048"
      provider.cpus = 4
      provider.graphics_type = "none"
      provider.video_type = "qxl"
    end
  end

  # compute-node-2 - 
  config.vm.define "compute-node-2" do |compute_node_2|
    compute_node_2.vm.hostname = "compute-node-2"
    compute_node_2.vm.network "private_network", ip: "192.168.50.15", libvirt__network_name: "onprem-network"
    compute_node_2.vm.network "private_network", ip: "192.168.60.10", libvirt__network_name: "cloud-network"
    compute_node_2.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add user's SSH key if not already present
      if ! grep -q "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
        echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" >> /home/vagrant/.ssh/authorized_keys
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    compute_node_2.vm.provider "libvirt" do |provider|
      # KVM/libvirt specific options
      provider.memory = "2048"
      provider.cpus = 4
      provider.graphics_type = "none"
      provider.video_type = "qxl"
    end
  end

  # nosql-node-1 - 
  config.vm.define "nosql-node-1" do |nosql_node_1|
    nosql_node_1.vm.hostname = "nosql-node-1"
    nosql_node_1.vm.network "private_network", ip: "192.168.50.16", libvirt__network_name: "onprem-network"
    nosql_node_1.vm.network "private_network", ip: "192.168.60.10", libvirt__network_name: "cloud-network"
    nosql_node_1.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add user's SSH key if not already present
      if ! grep -q "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
        echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" >> /home/vagrant/.ssh/authorized_keys
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    nosql_node_1.vm.provider "libvirt" do |provider|
      # KVM/libvirt specific options
      provider.memory = "1024"
      provider.cpus = 2
      provider.graphics_type = "none"
      provider.video_type = "qxl"
    end
  end

  # compute-node-3 - 
  config.vm.define "compute-node-3" do |compute_node_3|
    compute_node_3.vm.hostname = "compute-node-3"
    compute_node_3.vm.network "private_network", ip: "192.168.60.10", libvirt__network_name: "cloud-network"
    compute_node_3.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add user's SSH key if not already present
      if ! grep -q "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
        echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" >> /home/vagrant/.ssh/authorized_keys
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    compute_node_3.vm.provider "libvirt" do |provider|
      # KVM/libvirt specific options
      provider.memory = "2048"
      provider.cpus = 4
      provider.graphics_type = "none"
      provider.video_type = "qxl"
    end
  end

  # compute-node-4 - 
  config.vm.define "compute-node-4" do |compute_node_4|
    compute_node_4.vm.hostname = "compute-node-4"
    compute_node_4.vm.network "private_network", ip: "192.168.60.11", libvirt__network_name: "cloud-network"
    compute_node_4.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add user's SSH key if not already present
      if ! grep -q "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
        echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" >> /home/vagrant/.ssh/authorized_keys
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    compute_node_4.vm.provider "libvirt" do |provider|
      # KVM/libvirt specific options
      provider.memory = "2048"
      provider.cpus = 4
      provider.graphics_type = "none"
      provider.video_type = "qxl"
    end
  end

  # nosql-node-2 - 
  config.vm.define "nosql-node-2" do |nosql_node_2|
    nosql_node_2.vm.hostname = "nosql-node-2"
    nosql_node_2.vm.network "private_network", ip: "192.168.60.12", libvirt__network_name: "cloud-network"
    nosql_node_2.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add user's SSH key if not already present
      if ! grep -q "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
        echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMxjyHe1rJlBxzZJCCVXLI7qkbt0Cc9XX71gG83OO/b ubuntu@bigrig" >> /home/vagrant/.ssh/authorized_keys
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
    nosql_node_2.vm.provider "libvirt" do |provider|
      # KVM/libvirt specific options
      provider.memory = "1024"
      provider.cpus = 2
      provider.graphics_type = "none"
      provider.video_type = "qxl"
    end
  end

  # Note: Ansible provisioning is run manually after all VMs are up
  # Run: ansible-playbook -i inventory/hosts playbooks/site.yml
end
