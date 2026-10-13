#!/bin/bash
# Dynamic Vagrantfile generator for Burst-A-Flat
# Supports kvm (default), virtualbox, and vsphere

set -e

CONFIG_FILE="config.yml"
VAGRANTFILE="Vagrantfile"

# True when a line starts a sibling VM block under vms: (2-space indent, name:)
is_vm_header() {
    [[ "$1" =~ ^[[:space:]]{2}[a-zA-Z0-9_-]+:[[:space:]]*$ ]]
}

# Function to read YAML values (simple implementation)
read_yaml() {
    local key="$1"
    local file="$2"
    grep "^${key}:" "$file" | sed "s/^${key}:[[:space:]]*//" | tr -d '"' | tr -d "'"
}

# Function to read nested YAML values under a top-level section (e.g. providers.box)
# Scoped to the active provider subsection when section is "providers".
read_yaml_nested() {
    local section="$1"
    local key="$2"
    local file="$3"
    local in_section=false
    local in_provider=false
    local provider
    provider=$(read_yaml "provider" "$file")
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^${section}: ]]; then
            in_section=true
            continue
        fi
        if [[ "$line" =~ ^[a-zA-Z] ]] && [[ ! "$line" =~ ^[[:space:]] ]]; then
            in_section=false
            in_provider=false
        fi
        if [[ "$in_section" != true ]]; then
            continue
        fi
        # Under providers:, only read keys for the active provider
        if [[ "$section" == "providers" ]]; then
            if [[ "$line" =~ ^[[:space:]]{2}${provider}: ]]; then
                in_provider=true
                continue
            fi
            if is_vm_header "$line" || [[ "$line" =~ ^[[:space:]]{2}[a-zA-Z0-9_-]+: ]]; then
                if [[ ! "$line" =~ ^[[:space:]]{2}${provider}: ]]; then
                    in_provider=false
                fi
            fi
            if [[ "$in_provider" != true ]]; then
                continue
            fi
        fi
        if [[ "$line" =~ ^[[:space:]]+${key}: ]]; then
            echo "$line" | sed "s/^[[:space:]]*${key}:[[:space:]]*//" | tr -d '"' | tr -d "'"
            return
        fi
    done < "$file"
}

# Function to get VM configuration (scoped to a single VM block under vms:)
get_vm_config() {
    local vm_name="$1"
    local key="$2"
    local file="$3"
    local in_vm=false
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]{2}${vm_name}:[[:space:]]*$ ]]; then
            in_vm=true
            continue
        fi
        if [[ "$in_vm" == true ]]; then
            # Next VM at the same indent, or a new top-level key
            if is_vm_header "$line" || [[ "$line" =~ ^[a-zA-Z] ]]; then
                return
            fi
            if [[ "$line" =~ ^[[:space:]]+${key}: ]]; then
                echo "$line" | sed "s/^[[:space:]]*${key}:[[:space:]]*//" | tr -d '"' | tr -d "'"
                return
            fi
        fi
    done < "$file"
}

# Function to get roles as comma-separated string
get_vm_roles() {
    local vm_name="$1"
    local file="$2"
    local in_vm=false
    local in_roles=false
    local roles=""
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]{2}${vm_name}:[[:space:]]*$ ]]; then
            in_vm=true
            continue
        fi
        if [[ "$in_vm" != true ]]; then
            continue
        fi
        if is_vm_header "$line" || [[ "$line" =~ ^[a-zA-Z] ]]; then
            break
        fi
        if [[ "$line" =~ ^[[:space:]]+roles: ]]; then
            in_roles=true
            continue
        fi
        if [[ "$in_roles" == true ]]; then
            if [[ "$line" =~ ^[[:space:]]+-[[:space:]]* ]]; then
                local role
                role=$(echo "$line" | sed "s/^[[:space:]]*-[[:space:]]*//" | tr -d '"' | tr -d "'")
                if [[ -n "$roles" ]]; then
                    roles="${roles}, ${role}"
                else
                    roles="$role"
                fi
            else
                break
            fi
        fi
    done < "$file"
    echo "$roles"
}

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: $CONFIG_FILE not found"
    exit 1
fi

# Get provider from command line argument
PROVIDER="$1"
if [[ -z "$PROVIDER" ]]; then
    echo "Usage: $0 <virtualbox|vsphere|kvm>"
    exit 1
fi

if [[ "$PROVIDER" != "virtualbox" && "$PROVIDER" != "vsphere" && "$PROVIDER" != "kvm" ]]; then
    echo "Error: Invalid provider. Use 'virtualbox', 'vsphere', or 'kvm'"
    exit 1
fi

# Update config.yml with the specified provider
sed -i "s/^provider:.*/provider: \"$PROVIDER\"/" "$CONFIG_FILE"
echo "Updated config.yml to use $PROVIDER"

# Read configuration values
BOX=$(read_yaml_nested "providers" "box" "$CONFIG_FILE")
NETWORK_TYPE=$(read_yaml_nested "providers" "network_type" "$CONFIG_FILE")

# Get provider-specific network options
if [[ "$PROVIDER" == "virtualbox" ]]; then
    NETWORK1_OPTION="virtualbox__hostonly"
    NETWORK2_OPTION="virtualbox__hostonly"
    PROVIDER_NAME="virtualbox"
elif [[ "$PROVIDER" == "kvm" ]]; then
    NETWORK1_OPTION="libvirt__network_name"
    NETWORK2_OPTION="libvirt__network_name"
    PROVIDER_NAME="libvirt"
else
    NETWORK1_OPTION="vsphere__intnet"
    NETWORK2_OPTION="vsphere__intnet"
    PROVIDER_NAME="vsphere"
fi

# Generate Vagrantfile header
cat > "$VAGRANTFILE" << EOF
# -*- mode: ruby -*-
# vi: set ft=ruby :
# Generated Vagrantfile for Burst-A-Flat
# Provider: $PROVIDER
# Generated on: $(date)

Vagrant.configure("2") do |config|
  # Global configuration
  config.vm.box = "$BOX"
  config.vm.box_check_update = false
  
  # Network configuration - removed global config to avoid conflicts
  
  # Provider configuration
EOF

# Add provider-specific global configuration
if [[ "$PROVIDER" == "kvm" ]]; then
    cat >> "$VAGRANTFILE" << EOF
  # KVM/libvirt global configuration
  config.vm.provider "libvirt" do |libvirt|
    libvirt.memory = "1024"
    libvirt.cpus = 2
    libvirt.graphics_type = "none"
    libvirt.video_type = "qxl"
    # Suppress fog warnings
    libvirt.uri = "qemu:///system"
  end
EOF
else
    cat >> "$VAGRANTFILE" << EOF
  config.vm.provider "$PROVIDER_NAME" do |provider|
    provider.name = "login-node"
    provider.memory = "1024"
    provider.cpus = 2
    provider.gui = false
  end
EOF
fi

# Check if user has SSH key
USER_SSH_KEY=""
if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
    USER_SSH_KEY="$HOME/.ssh/id_ed25519.pub"
elif [[ -f "$HOME/.ssh/id_rsa.pub" ]]; then
    USER_SSH_KEY="$HOME/.ssh/id_rsa.pub"
fi

# Generate VM definitions - get VM names from the vms section
VMS=$(awk '/^vms:/{flag=1;next} /^[a-zA-Z]/ && !/^[[:space:]]/{flag=0} flag && /^[[:space:]]*(login-node|management-node|controller-node|slurmdb-node|compute-node-[0-9]|nosql-node-[0-9]):/{gsub(/^[[:space:]]*/, ""); gsub(/:.*/, ""); print}' "$CONFIG_FILE")

for vm_name in $VMS; do
    HOSTNAME=$(get_vm_config "$vm_name" "hostname" "$CONFIG_FILE")
    MEMORY=$(get_vm_config "$vm_name" "memory" "$CONFIG_FILE")
    CPUS=$(get_vm_config "$vm_name" "cpus" "$CONFIG_FILE")
    ROLES=$(get_vm_roles "$vm_name" "$CONFIG_FILE")
    
    # Determine network and IP
    IP_NETWORK1=$(get_vm_config "$vm_name" "ip_network1" "$CONFIG_FILE")
    IP_NETWORK2=$(get_vm_config "$vm_name" "ip_network2" "$CONFIG_FILE")
    
    # Convert VM name to variable name (replace hyphens with underscores)
    VM_VAR=$(echo "$vm_name" | sed 's/-/_/g')
    
    # Add VM definition to Vagrantfile
    cat >> "$VAGRANTFILE" << EOF
  # $HOSTNAME - $ROLES
  config.vm.define "$vm_name" do |$VM_VAR|
    $VM_VAR.vm.hostname = "$HOSTNAME"
EOF

    # Add network interfaces
    if [[ -n "$IP_NETWORK1" ]]; then
        cat >> "$VAGRANTFILE" << EOF
    $VM_VAR.vm.network "$NETWORK_TYPE", ip: "$IP_NETWORK1", $NETWORK1_OPTION: "onprem-network"
EOF
    fi
    
    if [[ -n "$IP_NETWORK2" ]]; then
        cat >> "$VAGRANTFILE" << EOF
    $VM_VAR.vm.network "$NETWORK_TYPE", ip: "$IP_NETWORK2", $NETWORK2_OPTION: "cloud-network"
EOF
    fi

    # Add SSH key configuration - always add user key if available
    if [[ -n "$USER_SSH_KEY" ]]; then
        cat >> "$VAGRANTFILE" << EOF
    $VM_VAR.vm.provision "shell", inline: <<-SHELL
      # Ensure .ssh directory exists
      mkdir -p /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      
      # Add user's SSH key if not already present
      if ! grep -q "$(cat $USER_SSH_KEY)" /home/vagrant/.ssh/authorized_keys 2>/dev/null; then
        echo "$(cat $USER_SSH_KEY)" >> /home/vagrant/.ssh/authorized_keys
      fi
      
      # Set proper ownership and permissions
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      
      # Ensure the directory has correct ownership too
      chown vagrant:vagrant /home/vagrant/.ssh
    SHELL
EOF
    fi

    # Add KVM-specific networking for controller node (gateway)
    if [[ "$vm_name" == "controller-node" && "$PROVIDER" == "kvm" ]]; then
        cat >> "$VAGRANTFILE" << EOF
    # Add NAT for internet access (controller acts as gateway)
    $VM_VAR.vm.network "private_network", type: "nat", ip: "10.0.2.10"
EOF
    fi

    cat >> "$VAGRANTFILE" << EOF
    $VM_VAR.vm.provider "$PROVIDER_NAME" do |provider|
EOF

    # Add provider-specific options
    if [[ "$PROVIDER" == "kvm" ]]; then
        cat >> "$VAGRANTFILE" << EOF
      # KVM/libvirt specific options
      provider.memory = "$MEMORY"
      provider.cpus = $CPUS
      provider.graphics_type = "none"
      provider.video_type = "qxl"
EOF
    else
        cat >> "$VAGRANTFILE" << EOF
      provider.name = "$vm_name"
      provider.memory = "$MEMORY"
      provider.cpus = $CPUS
EOF
    fi

    cat >> "$VAGRANTFILE" << EOF
    end
  end

EOF
done

# Generate Vagrantfile footer
cat >> "$VAGRANTFILE" << EOF
  # Note: Ansible provisioning is run manually after all VMs are up
  # Run: ansible-playbook -i inventory/hosts playbooks/site.yml
end
EOF

echo "Generated Vagrantfile for $PROVIDER"
