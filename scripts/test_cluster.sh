#!/bin/bash
# Test script for Burst-A-Flat Slurm cluster

echo "=== Burst-A-Flat Cluster Test ==="
echo "Date: $(date)"
echo ""

# Test 1: Check cluster status
echo "Test 1: Checking cluster status..."
sinfo
if [ $? -eq 0 ]; then
    echo "✅ Cluster status check passed"
else
    echo "❌ Cluster status check failed"
    exit 1
fi
echo ""

# Test 2: Check node availability
echo "Test 2: Checking node availability..."
scontrol show nodes
if [ $? -eq 0 ]; then
    echo "✅ Node availability check passed"
else
    echo "❌ Node availability check failed"
    exit 1
fi
echo ""

# Test 3: Check partitions
echo "Test 3: Checking partitions..."
scontrol show partition
if [ $? -eq 0 ]; then
    echo "✅ Partition check passed"
else
    echo "❌ Partition check failed"
    exit 1
fi
echo ""

# Test 4: Submit a simple job
echo "Test 4: Submitting test job..."
cat > /tmp/test_job.sh << 'EOF'
#!/bin/bash
#SBATCH --job-name=test_job
#SBATCH --output=/tmp/test_job_%j.out
#SBATCH --error=/tmp/test_job_%j.err
#SBATCH --time=00:01:00
#SBATCH --nodes=1
#SBATCH --ntasks=1

echo "Test job running on node: $(hostname)"
echo "Date: $(date)"
echo "Job ID: $SLURM_JOB_ID"
echo "Test completed successfully!"
EOF

chmod +x /tmp/test_job.sh
job_id=$(sbatch /tmp/test_job.sh | awk '{print $4}')
echo "Job submitted with ID: $job_id"

# Wait for job to complete
echo "Waiting for job to complete..."
sleep 10

# Check job status
squeue -j $job_id
if [ $? -eq 0 ]; then
    echo "✅ Test job submitted successfully"
else
    echo "❌ Test job submission failed"
    exit 1
fi
echo ""

# Test 5: Check NFS mount
echo "Test 5: Checking NFS mount..."
if [ -d "/home/vagrant/shared" ]; then
    echo "✅ NFS mount accessible"
    ls -la /home/vagrant/shared/
else
    echo "❌ NFS mount not accessible"
    exit 1
fi
echo ""

# Test 6: Check MongoDB connectivity
echo "Test 6: Checking MongoDB connectivity..."
if command -v mongosh &> /dev/null; then
    mongosh --eval "db.runCommand('ping')" --quiet
    if [ $? -eq 0 ]; then
        echo "✅ MongoDB connectivity check passed"
    else
        echo "❌ MongoDB connectivity check failed"
    fi
else
    echo "⚠️  MongoDB client not available, skipping test"
fi
echo ""

# Test 7: Check R environment
echo "Test 7: Checking R environment..."
R --slave -e "cat('R version:', R.version.string, '\n')"
if [ $? -eq 0 ]; then
    echo "✅ R environment check passed"
else
    echo "❌ R environment check failed"
    exit 1
fi
echo ""

echo "=== Cluster Test Summary ==="
echo "All tests completed successfully!"
echo "Cluster is ready for use."
echo ""
echo "Next steps:"
echo "1. Submit the R workload demo: sbatch /home/vagrant/shared/scripts/r_workload_demo.sh"
echo "2. Monitor jobs: squeue"
echo "3. Check job output: ls /home/vagrant/shared/results/"
