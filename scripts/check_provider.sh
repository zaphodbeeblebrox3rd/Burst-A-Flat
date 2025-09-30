#!/bin/bash
# Check which virtualization provider is available and configured

echo "=== Burst-A-Flat Provider Check ==="
echo ""

# Check if config.yml exists
if [ ! -f "config.yml" ]; then
    echo "❌ config.yml not found. Run setup.sh first."
    exit 1
fi

# Read current provider from config
current_provider=$(grep "provider:" config.yml | awk '{print $2}' | tr -d '"')
echo "Current provider in config: $current_provider"
echo ""

# Check VirtualBox
echo "=== VirtualBox Check ==="
if command -v VBoxManage &> /dev/null; then
    vbox_version=$(VBoxManage --version)
    echo "✅ VirtualBox installed: $vbox_version"
    
    # Check if VirtualBox is running
    if VBoxManage list runningvms &> /dev/null; then
        running_vms=$(VBoxManage list runningvms | wc -l)
        echo "   Running VMs: $running_vms"
    fi
else
    echo "❌ VirtualBox not found"
fi
echo ""

# Check VMware
echo "=== vSphere Check ==="
if command -v vmrun &> /dev/null; then
    echo "✅ vSphere found"
    
    # Check if VMware is running
    if vmrun list &> /dev/null; then
        running_vms=$(vmrun list | grep -c "Total running VMs:")
        echo "   Running VMs: $running_vms"
    fi
else
    echo "❌ vSphere not found"
fi
echo ""

# Check Vagrant
echo "=== Vagrant Check ==="
if command -v vagrant &> /dev/null; then
    vagrant_version=$(vagrant --version)
    echo "✅ Vagrant installed: $vagrant_version"
    
    # Check Vagrant plugins
    if vagrant plugin list | grep -q "vagrant-vmware-workstation"; then
        echo "✅ VMware plugin installed"
    else
        echo "⚠️  VMware plugin not installed (required for VMware provider)"
    fi
else
    echo "❌ Vagrant not found"
fi
echo ""

# Check Ansible
echo "=== Ansible Check ==="
if command -v ansible &> /dev/null; then
    ansible_version=$(ansible --version | head -1)
    echo "✅ Ansible installed: $ansible_version"
else
    echo "❌ Ansible not found"
fi
echo ""

# Recommendations
echo "=== Recommendations ==="
if [ "$current_provider" = "virtualbox" ]; then
    if command -v VBoxManage &> /dev/null; then
        echo "✅ Ready to use VirtualBox"
    else
        echo "❌ VirtualBox not installed. Please install VirtualBox or switch to VMware."
    fi
elif [ "$current_provider" = "vsphere" ]; then
    if command -v vmrun &> /dev/null && vagrant plugin list | grep -q "vagrant-vsphere"; then
        echo "✅ Ready to use vSphere"
    else
        echo "❌ vSphere or plugin not properly installed."
    fi
else
    echo "❌ Unknown provider: $current_provider"
fi

echo ""
echo "=== Next Steps ==="
echo "1. If everything looks good: vagrant up"
echo "2. To switch providers: ./setup.sh"
echo "3. For help: see README.md"
