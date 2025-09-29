#!/usr/bin/env ruby
# Dynamic Vagrantfile generator for Burst-A-Flat
# Supports both VirtualBox and VMware Workstation Pro

require 'yaml'

class VagrantfileGenerator
  def initialize(config_file = 'config.yml')
    @config = YAML.load_file(config_file)
    @provider = @config['provider']
    @provider_config = @config['providers'][@provider]
    @vms = @config['vms']
  end

  def generate
    vagrantfile_content = generate_header + generate_vm_definitions + generate_footer
    File.write('Vagrantfile', vagrantfile_content)
    puts "Generated Vagrantfile for #{@provider}"
  end

  private

  def generate_header
    <<~HEADER
      # -*- mode: ruby -*-
      # vi: set ft=ruby :
      # Generated Vagrantfile for Burst-A-Flat
      # Provider: #{@provider}
      # Generated on: #{Time.now}

      Vagrant.configure("2") do |config|
        # Global configuration
        config.vm.box = "#{@provider_config['box']}"
        config.vm.box_check_update = false
        
        # Network configuration
        config.vm.network "#{@provider_config['network_type']}", ip: "192.168.50.10", #{@provider_config['network_options']['network1']}: "network1"
        config.vm.network "#{@provider_config['network_type']}", ip: "192.168.60.10", #{@provider_config['network_options']['network2']}: "network2"
        
        # Provider configuration
        config.vm.provider "#{@provider}" do |provider|
          provider.name = "login-node"
          provider.memory = "1024"
          provider.cpus = 2
          provider.gui = false
        end

    HEADER
  end

  def generate_vm_definitions
    vm_definitions = ""
    
    @vms.each do |vm_name, vm_config|
      vm_definitions += generate_vm_definition(vm_name, vm_config)
    end
    
    vm_definitions
  end

  def generate_vm_definition(vm_name, vm_config)
    network_ip = vm_config['ip_network1'] || vm_config['ip_network2']
    network_num = vm_config['ip_network1'] ? '1' : '2'
    
    <<~VM_DEFINITION
      # #{vm_config['hostname']} - #{vm_config['roles'].join(', ')}
      config.vm.define "#{vm_name}" do |#{vm_name.gsub('-', '_')}|
        #{vm_name.gsub('-', '_')}.vm.hostname = "#{vm_config['hostname']}"
        #{vm_name.gsub('-', '_')}.vm.network "#{@provider_config['network_type']}", ip: "#{network_ip}", #{@provider_config['network_options']["network#{network_num}"]}: "network#{network_num}"
        #{vm_name.gsub('-', '_')}.vm.provider "#{@provider}" do |provider|
          provider.name = "#{vm_name}"
          provider.memory = "#{vm_config['memory']}"
          provider.cpus = #{vm_config['cpus']}
        end
      end

    VM_DEFINITION
  end

  def generate_footer
    <<~FOOTER
      # Provision all nodes with Ansible
      config.vm.provision "ansible" do |ansible|
        ansible.playbook = "playbooks/site.yml"
        ansible.inventory_path = "inventory/hosts"
        ansible.limit = "all"
        ansible.extra_vars = {
          ansible_user: "vagrant",
          ansible_ssh_private_key_file: "~/.vagrant.d/insecure_private_key"
        }
      end
    end
    end
    FOOTER
  end
end

# Generate Vagrantfile
if ARGV.length > 0
  provider = ARGV[0]
  if ['virtualbox', 'vmware_workstation'].include?(provider)
    # Update config.yml with the specified provider
    config = YAML.load_file('config.yml')
    config['provider'] = provider
    File.write('config.yml', config.to_yaml)
    puts "Updated config.yml to use #{provider}"
  else
    puts "Invalid provider. Use: virtualbox or vmware_workstation"
    exit 1
  end
end

generator = VagrantfileGenerator.new
generator.generate
