#!/bin/bash
# Burst-A-Flat Setup Script
# Sets up KVM/libvirt for cloud burst simulation

set -e

echo "=== Burst-A-Flat Setup ==="
echo "Setting up KVM/libvirt for cloud burst simulation..."
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "❌ This script should not be run as root"
   echo "Please run as a regular user (sudo will be used when needed)"
   exit 1
fi

# Check if KVM is available
if ! lsmod | grep -q kvm; then
    echo "❌ KVM module not loaded"
    echo "Please ensure KVM is available on your system"
    exit 1
fi

echo "✅ KVM module detected"

# Install required packages
echo "📦 Installing KVM/libvirt packages..."
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager

# Add user to libvirt group
echo "👤 Adding user to libvirt group..."
sudo usermod -a -G libvirt $USER
sudo usermod -a -G kvm $USER

# Install vagrant-libvirt plugin
echo "🔌 Installing vagrant-libvirt plugin..."
vagrant plugin install vagrant-libvirt

# Stop VirtualBox services to avoid conflicts
echo "🛑 Stopping VirtualBox services..."
sudo systemctl stop vboxdrv 2>/dev/null || true
sudo systemctl disable vboxdrv 2>/dev/null || true

# Generate Vagrantfile for KVM
echo "📝 Generating Vagrantfile for KVM/libvirt..."
bash scripts/generate_vagrantfile.sh kvm

echo ""
echo "=== Setup Complete ==="
echo "✅ KVM/libvirt setup complete"
echo ""
echo "⚠️  IMPORTANT: You need to log out and log back in (or reboot) for group changes to take effect"
echo ""
echo "Next steps:"
echo "1. Log out and log back in (or reboot)"
echo "2. Run: vagrant up"
echo "3. Configure the cluster: ansible-playbook -i inventory/hosts playbooks/site.yml"
echo ""
echo "For troubleshooting:"
echo "  - Check libvirt status: sudo systemctl status libvirtd"
echo "  - Check user groups: groups $USER"
echo "  - Check KVM: lsmod | grep kvm"
