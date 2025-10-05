#!/bin/bash
# Cluster monitoring script for Burst-A-Flat

echo "=== Burst-A-Flat Cluster Monitor ==="
echo "Date: $(date)"
echo ""

# Function to check service status
check_service() {
    local service=$1
    local host=$2
    
    if [ -n "$host" ]; then
        status=$(vagrant ssh $host -c "systemctl is-active $service" 2>/dev/null)
    else
        status=$(systemctl is-active $service 2>/dev/null)
    fi
    
    if [ "$status" = "active" ]; then
        echo "✅ $service: Running"
    else
        echo "❌ $service: Not running"
    fi
}

# Check Slurm services
echo "=== Slurm Services ==="
check_service "slurmctld" "controller-node"
check_service "slurmd" "controller-node"
check_service "slurmd" "compute-node-1"
check_service "slurmd" "compute-node-2"
check_service "slurmd" "compute-node-3"
check_service "slurmd" "compute-node-4"
echo ""

# Check database services
echo "=== Database Services ==="
check_service "mariadb" "slurmdb-node"
check_service "mongod" "nosql-node-1"
check_service "mongod" "nosql-node-2"
echo ""

# Check NFS services
echo "=== NFS Services ==="
check_service "nfs-kernel-server" "controller-node"
check_service "rpcbind" "controller-node"
echo ""

# Check cluster status
echo "=== Cluster Status ==="
vagrant ssh login-node -c "sinfo" 2>/dev/null
echo ""

# Check job queue
echo "=== Job Queue ==="
vagrant ssh login-node -c "squeue" 2>/dev/null
echo ""

# Check node status
echo "=== Node Status ==="
vagrant ssh login-node -c "scontrol show nodes" 2>/dev/null | grep -E "(NodeName|State|CPUTot|CPULoad)"
echo ""

# Check NFS mounts
echo "=== NFS Mounts ==="
vagrant ssh login-node -c "df -h | grep shared" 2>/dev/null
echo ""

# Check MongoDB status
echo "=== MongoDB Status ==="
vagrant ssh nosql-node-1 -c "mongosh --eval 'db.runCommand(\"ping\")' --quiet" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ MongoDB Primary: Connected"
else
    echo "❌ MongoDB Primary: Not connected"
fi

vagrant ssh nosql-node-2 -c "mongosh --eval 'db.runCommand(\"ping\")' --quiet" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ MongoDB Replica: Connected"
else
    echo "❌ MongoDB Replica: Not connected"
fi
echo ""

# Check disk usage
echo "=== Disk Usage ==="
vagrant ssh controller-node -c "df -h /home/shared" 2>/dev/null
echo ""

# Check memory usage
echo "=== Memory Usage ==="
vagrant ssh controller-node -c "free -h" 2>/dev/null
echo ""

echo "=== Monitor Complete ==="
echo "For detailed logs, check:"
echo "  - Slurm: /var/log/slurm/"
echo "  - MongoDB: /var/log/mongodb/"
echo "  - NFS: /var/log/nfs/"
