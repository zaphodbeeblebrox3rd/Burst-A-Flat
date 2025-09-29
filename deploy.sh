#!/bin/bash
# Deployment script for Burst-A-Flat Slurm cluster

set -e

echo "=== Burst-A-Flat Slurm Cluster Deployment ==="
echo "Date: $(date)"
echo ""

# Check prerequisites
echo "Checking prerequisites..."

# Check if Vagrant is installed
if ! command -v vagrant &> /dev/null; then
    echo "ERROR: Vagrant is not installed. Please install Vagrant first."
    exit 1
fi

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "ERROR: Ansible is not installed. Please install Ansible first."
    exit 1
fi

# Check if VirtualBox is installed
if ! command -v VBoxManage &> /dev/null; then
    echo "ERROR: VirtualBox is not installed. Please install VirtualBox first."
    exit 1
fi

echo "✅ All prerequisites found"
echo ""

# Create necessary directories
echo "Creating directories..."
mkdir -p data
mkdir -p results
mkdir -p logs
echo "✅ Directories created"
echo ""

# Deploy VMs
echo "Deploying virtual machines..."
echo "This may take 10-15 minutes..."
vagrant up
echo "✅ Virtual machines deployed"
echo ""

# Configure cluster
echo "Configuring Slurm cluster..."
echo "This may take 5-10 minutes..."
ansible-playbook -i inventory/hosts playbooks/site.yml
echo "✅ Cluster configured"
echo ""

# Generate test data
echo "Generating test data..."
vagrant ssh controller-node -c "Rscript /home/vagrant/shared/scripts/generate_test_data.R"
echo "✅ Test data generated"
echo ""

# Test cluster
echo "Testing cluster..."
vagrant ssh login-node -c "sinfo"
echo "✅ Cluster test completed"
echo ""

echo "=== Deployment Complete ==="
echo ""
echo "To use the cluster:"
echo "1. Login: vagrant ssh login-node"
echo "2. Check status: sinfo"
echo "3. Submit job: sbatch /home/vagrant/shared/scripts/r_workload_demo.sh"
echo "4. Monitor jobs: squeue"
echo ""
echo "Cluster nodes:"
echo "  - Login: login-node"
echo "  - Controller: controller-node"
echo "  - Compute: compute-node-1, compute-node-2, compute-node-3, compute-node-4"
echo "  - Database: slurmdb-node"
echo "  - NoSQL: nosql-node-1, nosql-node-2"
echo ""
echo "For more information, see README.md"
