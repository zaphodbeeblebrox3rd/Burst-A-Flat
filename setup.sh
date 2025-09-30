#!/bin/bash
# Burst-A-Flat Setup Script
# Allows users to choose between VirtualBox and vSphere

set -e

echo "=== Burst-A-Flat Setup ==="
echo "Choose your virtualization provider:"
echo "1) VirtualBox (default)"
echo "2) vSphere"
echo "3) Exit"
echo ""

read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo "Setting up for VirtualBox..."
        bash scripts/generate_vagrantfile.sh virtualbox
        echo "✅ VirtualBox Vagrantfile generated"
        ;;
    2)
        echo "Setting up for vSphere..."
        bash scripts/generate_vagrantfile.sh vsphere
        echo "✅ vSphere Vagrantfile generated"
        ;;
    3)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice. Using VirtualBox as default..."
        bash scripts/generate_vagrantfile.sh virtualbox
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
echo "For vSphere users:"
echo "  - vSphere must be installed"
echo "  - Vagrant vSphere plugin: vagrant plugin install vagrant-vsphere"
