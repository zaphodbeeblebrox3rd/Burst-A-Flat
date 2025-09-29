# Burst-A-Flat Architecture

## Overview

Burst-A-Flat is a Slurm cluster designed to demonstrate cloud burst scenarios where traditional shared storage (NFS) fails, but NoSQL databases provide the solution for distributed data access.

## Network Architecture

### Network 1 (On-Premises) - 192.168.50.0/24
- **login-node** (192.168.50.10): User access point
- **management-node** (192.168.50.11): Cluster administration
- **controller-node** (192.168.50.12): Slurm controller + NFS server
- **slurmdb-node** (192.168.50.13): MariaDB for Slurm accounting
- **compute-node-1** (192.168.50.14): Cluster compute node
- **compute-node-2** (192.168.50.15): Cluster compute node
- **nosql-node-1** (192.168.50.16): MongoDB primary instance

### Network 2 (Cloud Simulation) - 192.168.60.0/24
- **compute-node-3** (192.168.60.10): Cloud compute node
- **compute-node-4** (192.168.60.11): Cloud compute node
- **nosql-node-2** (192.168.60.12): MongoDB replica instance

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
- **NFS Clients**: Network 1 nodes mount shared storage
- **NoSQL Database**: MongoDB replication between networks

### Database Architecture
- **MariaDB**: Slurm accounting database
- **MongoDB**: Distributed data storage with replication
  - Primary: nosql-node-1 (Network 1)
  - Replica: nosql-node-2 (Network 2)

## Data Flow

### Traditional Workflow (Network 1)
1. User submits job via login-node
2. Job accesses data from NFS share
3. Job executes on compute nodes
4. Results stored back to NFS

### Cloud Burst Workflow (Network 2)
1. User submits job via login-node
2. Job cannot access NFS (simulated cloud environment)
3. Job accesses data from MongoDB replica
4. Results stored to MongoDB

## Key Features

### High Availability
- MongoDB replication ensures data availability
- Multiple compute nodes provide redundancy
- Slurm handles job failover

### Scalability
- Easy addition of compute nodes
- MongoDB horizontal scaling
- Slurm dynamic node management

### Monitoring
- Slurm job monitoring
- MongoDB replication status
- NFS mount status
- System resource monitoring

## Security Considerations

### Network Isolation
- Separate networks for on-premises and cloud
- Firewall rules between networks
- VPN simulation for cloud access

### Authentication
- Munge for Slurm authentication
- SSH key-based access
- Database user authentication

### Data Protection
- MongoDB authentication
- NFS access controls
- Slurm job isolation

## Performance Characteristics

### Network 1 (On-Premises)
- Low latency NFS access
- High bandwidth shared storage
- Direct database access

### Network 2 (Cloud)
- Higher latency MongoDB access
- Network-dependent performance
- Replicated data consistency

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
- Data synchronization

## Troubleshooting

### Common Issues
1. **NFS Mount Failures**: Check controller node NFS service
2. **Slurm Communication**: Verify Munge keys are synchronized
3. **MongoDB Replication**: Check network connectivity between nodes
4. **Job Failures**: Check compute node resources and logs

### Monitoring Commands
```bash
# Check cluster status
sinfo

# Check job queue
squeue

# Check node status
scontrol show nodes

# Check MongoDB status
mongosh --eval "rs.status()"

# Check NFS mounts
df -h | grep shared
```

## Future Enhancements

### Planned Features
- Kubernetes integration
- GPU support
- Advanced monitoring
- Automated scaling
- Multi-cloud support

### Performance Optimizations
- SSD storage for MongoDB
- Network optimization
- Job scheduling improvements
- Data compression
