#!/bin/bash
# Cleanup script for Burst-A-Flat Slurm cluster

echo "=== Burst-A-Flat Cluster Cleanup ==="
echo "Date: $(date)"
echo ""

# Stop all VMs
echo "Stopping all virtual machines..."
vagrant halt
echo "✅ Virtual machines stopped"
echo ""

# Destroy all VMs
echo "Destroying all virtual machines..."
vagrant destroy -f
echo "✅ Virtual machines destroyed"
echo ""

# Clean up Vagrant files
echo "Cleaning up Vagrant files..."
rm -rf .vagrant/
echo "✅ Vagrant files cleaned"
echo ""

# Clean up results and logs
echo "Cleaning up results and logs..."
rm -rf results/
rm -rf logs/
rm -f *.out
rm -f *.err
echo "✅ Results and logs cleaned"
echo ""

# Clean up temporary files
echo "Cleaning up temporary files..."
rm -f /tmp/test_job.sh
rm -f /tmp/munge_key
rm -f /tmp/mongodb_initialized
rm -f /tmp/mongodb_replica_added
rm -f /tmp/r_packages_installed
echo "✅ Temporary files cleaned"
echo ""

echo "=== Cleanup Complete ==="
echo "All cluster resources have been removed."
echo "To redeploy, run: ./deploy.sh"
