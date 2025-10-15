#!/bin/bash
#SBATCH --job-name=example_job
#SBATCH --output=/home/vagrant/shared/results/example_%j.out
#SBATCH --error=/home/vagrant/shared/results/example_%j.err
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=1G
#SBATCH --partition=compute

# Example Slurm job script for Burst-A-Flat cluster
# This script demonstrates basic job submission and execution

echo "=== Example Job Execution ==="
echo "Job ID: $SLURM_JOB_ID"
echo "Node: $SLURM_JOB_NODELIST"
echo "Partition: $SLURM_JOB_PARTITION"
echo "Start time: $(date)"
echo ""

# Display system information
echo "=== System Information ==="
echo "Hostname: $(hostname)"
echo "CPU count: $(nproc)"
echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
echo "Disk space: $(df -h / | tail -1 | awk '{print $4}')"
echo ""

# Check network connectivity
echo "=== Network Connectivity ==="
echo "Network 1 (On-premises):"
ping -c 1 192.168.50.12 >/dev/null 2>&1 && echo "✅ Controller node reachable" || echo "❌ Controller node not reachable"
ping -c 1 192.168.50.13 >/dev/null 2>&1 && echo "✅ SlurmDB node reachable" || echo "❌ SlurmDB node not reachable"
echo ""

echo "Network 2 (Cloud simulation):"
ping -c 1 192.168.60.16 >/dev/null 2>&1 && echo "✅ Compute node 3 reachable" || echo "❌ Compute node 3 not reachable"
ping -c 1 192.168.60.17 >/dev/null 2>&1 && echo "✅ Compute node 4 reachable" || echo "❌ Compute node 4 not reachable"
echo ""

# Check NFS mount (only on Network 1)
if [[ "$SLURM_JOB_NODELIST" =~ compute-node-[12] ]]; then
    echo "=== NFS Mount Check ==="
    if [ -d "/home/vagrant/shared" ]; then
        echo "✅ NFS mount accessible"
        echo "Shared directory contents:"
        ls -la /home/vagrant/shared/ | head -10
    else
        echo "❌ NFS mount not accessible"
    fi
    echo ""
fi

# Check MongoDB connectivity
echo "=== MongoDB Connectivity ==="
if command -v mongosh &> /dev/null; then
    # Determine which MongoDB to connect to
    if [[ "$SLURM_JOB_NODELIST" =~ compute-node-[34] ]]; then
        # Network 2 - use replica
        mongo_host="nosql-node-2:27017"
    else
        # Network 1 - use primary
        mongo_host="nosql-node-1:27017"
    fi
    
    echo "Connecting to MongoDB at: $mongo_host"
    mongosh --eval "db.runCommand('ping')" --quiet $mongo_host 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ MongoDB connection successful"
        
        # Check if sample data exists
        data_count=$(mongosh --eval "db.sample_data.countDocuments()" --quiet $mongo_host 2>/dev/null)
        echo "Sample data records: $data_count"
    else
        echo "❌ MongoDB connection failed"
    fi
else
    echo "⚠️  MongoDB client not available"
fi
echo ""

# Perform some computational work
echo "=== Computational Work ==="
echo "Performing matrix multiplication..."
python3 -c "
import numpy as np
import time

# Create random matrices
size = 1000
A = np.random.rand(size, size)
B = np.random.rand(size, size)

# Perform matrix multiplication
start_time = time.time()
C = np.dot(A, B)
end_time = time.time()

print(f'Matrix size: {size}x{size}')
print(f'Computation time: {end_time - start_time:.2f} seconds')
print(f'Result shape: {C.shape}')
print(f'Result sum: {np.sum(C):.2f}')
"
echo ""

# Check job resources
echo "=== Job Resources ==="
echo "CPU usage: $(cat /proc/loadavg | awk '{print $1}')"
echo "Memory usage: $(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100.0}')"
echo "Disk usage: $(df / | tail -1 | awk '{print $5}')"
echo ""

# Create output file
echo "=== Creating Output ==="
output_file="/home/vagrant/shared/results/example_output_${SLURM_JOB_ID}.txt"
cat > "$output_file" << EOF
Example Job Output
Job ID: $SLURM_JOB_ID
Node: $SLURM_JOB_NODELIST
Start time: $(date)
End time: $(date)
Hostname: $(hostname)
CPU count: $(nproc)
Memory: $(free -h | grep Mem | awk '{print $2}')
EOF

echo "Output file created: $output_file"
echo ""

echo "=== Job Complete ==="
echo "End time: $(date)"
echo "Job completed successfully!"
