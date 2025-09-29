#!/bin/bash
# Burst-A-Flat Setup Script
# Allows users to choose between VirtualBox and VMware Workstation Pro

set -e

echo "=== Burst-A-Flat Setup ==="
echo "Choose your virtualization provider:"
echo "1) VirtualBox (default)"
echo "2) VMware Workstation Pro"
echo "3) Exit"
echo ""

read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo "Setting up for VirtualBox..."
        ruby scripts/generate_vagrantfile.rb virtualbox
        echo "✅ VirtualBox Vagrantfile generated"
        ;;
    2)
        echo "Setting up for VMware Workstation Pro..."
        ruby scripts/generate_vagrantfile.rb vmware_workstation
        echo "✅ VMware Vagrantfile generated"
        ;;
    3)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice. Using VirtualBox as default..."
        ruby scripts/generate_vagrantfile.rb virtualbox
        echo "✅ VirtualBox Vagrantfile generated"
        ;;
esac

echo ""
echo "=== Setup Complete ==="
echo "Your Vagrantfile has been generated for your chosen provider."
echo ""
echo "Next steps:"
echo "1. Make sure your chosen virtualization software is installed"
echo "2. Run: vagrant up"
echo "3. Configure the cluster: ansible-playbook -i inventory/hosts playbooks/site.yml"
echo ""
echo "For VirtualBox users:"
echo "  - VirtualBox must be installed"
echo "  - VirtualBox Extension Pack recommended"
echo ""
echo "For VMware users:"
echo "  - VMware Workstation Pro must be installed"
echo "  - Vagrant VMware plugin: vagrant plugin install vagrant-vmware-workstation"
