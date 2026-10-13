# Burst-A-Flat Architecture

## Overview

Burst-A-Flat is a Slurm cluster designed to demonstrate cloud burst scenarios where traditional shared storage (NFS) fails, but a sharded NoSQL database provides distributed data access across networks.

## Network Architecture

### Network 1 (On-Premises) - 192.168.50.0/24
- **login-node** (192.168.50.10): User access point
- **management-node** (192.168.50.11 / 192.168.60.11): Cluster administration and inter-network router
- **controller-node** (192.168.50.12): Slurm controller + NFS server + MongoDB config server
- **slurmdb-node** (192.168.50.13): MariaDB for Slurm accounting
- **compute-node-1** (192.168.50.14): Cluster compute node
- **compute-node-2** (192.168.50.15): Cluster compute node
- **nosql-node-1** (192.168.50.16): MongoDB shard + mongos router

### Network 2 (Cloud Simulation) - 192.168.60.0/24
- **compute-node-3** (192.168.60.16): Cloud compute node
- **compute-node-4** (192.168.60.17): Cloud compute node
- **nosql-node-2** (192.168.60.12): MongoDB shard + mongos router

## Component Details

### Slurm Configuration
- **Controller**: Manages job scheduling and resource allocation
- **Compute Nodes**: Execute jobs across both networks
- **Partitions**:
  - `compute`: All compute nodes
  - `network1`: On-premises nodes only
  - `network2`: Cloud nodes only

### Storage Architecture
- **NFS Server**: Controller node exports `/home/shared`
- **NFS Clients**: Network 1 nodes mount shared storage at `/home/vagrant/shared`
- **Network 2**: No full NFS home mount; results directory only (simulates cloud burst storage failure)

### Database Architecture
- **MariaDB**: Slurm accounting database on slurmdb-node
- **MongoDB sharding** (not cross-network replica sets):
  - Config server: controller-node:27019
  - Mongos routers: nosql-node-1:27017, nosql-node-2:27017
  - Shards: nosql-node-1:27018, nosql-node-2:27018
  - Composite shard key `{network_id, array_task}` for network-aware data locality

## Data Flow

### Traditional Workflow (Network 1)
1. User submits job via login-node
2. Job accesses data from NFS share
3. Job executes on compute nodes
4. Results stored back to NFS

### Cloud Burst Workflow (Network 2)
1. User submits job via login-node
2. Job cannot access full NFS home (simulated cloud environment)
3. Job connects to the local mongos router and reads/writes via the sharded cluster
4. Results can be written to MongoDB and/or the limited results NFS export

## Key Features

### High Availability
- Mongos on each network provides a local query router
- Multiple compute nodes provide redundancy
- Slurm handles job failover

### Scalability
- Easy addition of compute nodes
- MongoDB horizontal scaling via additional shards
- Slurm dynamic node management

### Monitoring
- Slurm job monitoring
- MongoDB shard status via `sh.status()` on mongos
- NFS mount status
- System resource monitoring

## Security Considerations

### Network Isolation
- Separate networks for on-premises and cloud
- Management node routes between networks
- VPN simulation for cloud access

### Authentication
- Munge for Slurm authentication
- SSH key-based access
- Database user authentication

### Data Protection
- MongoDB authentication can be enabled for non-lab use
- NFS access controls
- Slurm job isolation

## Performance Characteristics

### Network 1 (On-Premises)
- Low latency NFS access
- High bandwidth shared storage
- Local mongos to nearby shard

### Network 2 (Cloud)
- Higher latency for cross-network shard access when needed
- Network-dependent performance
- Local mongos keeps most traffic on-network when shard key is network-aware

## Use Cases

### Research Computing
- R data analysis workflows
- Machine learning pipelines
- Scientific simulations

### Cloud Burst Scenarios
- Seasonal workload spikes
- Disaster recovery
- Geographic distribution

### Hybrid Cloud
- On-premises primary compute
- Cloud backup and scaling
- Location-aware data access via sharding

## Troubleshooting

### Common Issues
1. **NFS Mount Failures**: Check controller node NFS service
2. **Slurm Communication**: Verify Munge keys are synchronized
3. **MongoDB Sharding**: Check config server, mongos, and shard replica-set init
4. **Job Failures**: Check compute node resources and logs

### Monitoring Commands
```bash
# Check cluster status
sinfo

# Check job queue
squeue

# Check node status
scontrol show nodes

# Check MongoDB shard status via mongos
mongosh --host nosql-node-1:27017 --eval "sh.status()"

# Check NFS mounts
df -h | grep shared
```
