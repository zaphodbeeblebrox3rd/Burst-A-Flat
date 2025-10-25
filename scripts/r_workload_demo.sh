#!/bin/bash
#SBATCH --job-name=r_workload_demo
#SBATCH --output=/home/vagrant/shared/results/r_workload_%j.out
#SBATCH --error=/home/vagrant/shared/results/r_workload_%j.err
#SBATCH --time=00:10:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=1G

# R Workload Demonstration Script
# This script demonstrates the cloud burst scenario where traditional
# shared storage fails but NoSQL database provides the solution

echo "Starting R Workload Demonstration..."
echo "Job ID: $SLURM_JOB_ID"
echo "Node: $SLURM_JOB_NODELIST"
echo "Date: $(date)"

# Create results directory if it doesn't exist
mkdir -p /home/vagrant/shared/results
mkdir -p /home/vagrant/shared/data

# Set proper permissions
chmod 755 /home/vagrant/shared/results
chmod 755 /home/vagrant/shared/data

# Debug information
echo "=== Debug Information ==="
echo "Current user: $(whoami)"
echo "Current directory: $(pwd)"
echo "Node hostname: $(hostname)"
echo "SLURM_JOB_NODELIST: $SLURM_JOB_NODELIST"
echo "SLURM_JOB_PARTITION: $SLURM_JOB_PARTITION"
echo ""

# Check if R is available and install required packages
echo "=== Checking R Environment ==="
if ! command -v R &> /dev/null; then
    echo "ERROR: R is not installed or not in PATH"
    exit 1
fi

echo "R version: $(R --version | head -1)"
echo ""

# Install required R packages if not available
echo "=== Installing R Packages ==="
R --slave -e "
if (!require('mongolite', quietly = TRUE)) {
  cat('Installing mongolite package...\n')
  install.packages('mongolite', repos = 'https://cran.r-project.org/')
}
if (!require('dplyr', quietly = TRUE)) {
  cat('Installing dplyr package...\n')
  install.packages('dplyr', repos = 'https://cran.r-project.org/')
}
if (!require('ggplot2', quietly = TRUE)) {
  cat('Installing ggplot2 package...\n')
  install.packages('ggplot2', repos = 'https://cran.r-project.org/')
}
cat('R packages check completed\n')
"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install R packages"
    exit 1
fi

echo ""

# Run the R demonstration
R --slave -e "
# Load required libraries
library(mongolite)
library(dplyr)
library(ggplot2)

# Function to demonstrate traditional storage failure
demonstrate_traditional_failure <- function() {
  cat('=== Traditional Storage Access (NFS) ===\n')
  
  # Try to access shared data file
  data_file <- '/home/vagrant/shared/data/sample_data.Rdata'
  
  if (file.exists(data_file)) {
    cat('SUCCESS: NFS file accessible\n')
    load(data_file)
    cat('Data loaded successfully from NFS\n')
    return(TRUE)
  } else {
    cat('FAILURE: NFS file not accessible (simulating cloud burst scenario)\n')
    return(FALSE)
  }
}

# Function to demonstrate NoSQL solution
demonstrate_nosql_solution <- function() {
  cat('\n=== NoSQL Database Access (MongoDB) ===\n')
  
  # Connect to MongoDB
  tryCatch({
    # Determine MongoDB host based on network
    # Use SLURM_JOB_NODELIST if available, otherwise fall back to hostname
    node_info <- if (nchar(Sys.getenv('SLURM_JOB_NODELIST')) > 0) {
      Sys.getenv('SLURM_JOB_NODELIST')
    } else {
      Sys.info()['nodename']
    }
    
    cat('Node information:', node_info, '\n')
    
    # Determine MongoDB host based on network
    if (grepl('compute-node-[3-4]', node_info)) {
      # Network 2 - use replica
      mongo_host <- 'nosql-node-2:27017'
      cat('Using Network 2 (Cloud) MongoDB replica\n')
    } else {
      # Network 1 - use primary
      mongo_host <- 'nosql-node-1:27017'
      cat('Using Network 1 (On-premises) MongoDB primary\n')
    }
    
    cat('Connecting to MongoDB at:', mongo_host, '\n')
    
    # Test connection first
    test_con <- mongo(collection = 'test', db = 'test', url = paste0('mongodb://', mongo_host))
    test_con$disconnect()
    cat('MongoDB connection test successful\n')
    
    # Connect to MongoDB
    con <- mongo(collection = 'sample_data', db = 'burst_a_flat', url = paste0('mongodb://', mongo_host))
    
    # Check if data exists
    data_count <- con$count()
    cat('Records in MongoDB:', data_count, '\n')
    
    if (data_count > 0) {
      cat('SUCCESS: Data accessible via MongoDB\n')
      
      # Retrieve and process data
      data <- con$find('{}', limit = 100)
      cat('Retrieved', nrow(data), 'records from MongoDB\n')
      
      # Perform some analysis
      if (nrow(data) > 0) {
        summary_stats <- data %>%
          summarise(
            count = n(),
            mean_value = mean(value, na.rm = TRUE),
            median_value = median(value, na.rm = TRUE)
          )
        
        cat('Summary Statistics:\n')
        print(summary_stats)
      }
      
      con$disconnect()
      return(TRUE)
    } else {
      cat('No data found in MongoDB\n')
      con$disconnect()
      return(FALSE)
    }
    
  }, error = function(e) {
    cat('ERROR: Failed to connect to MongoDB:', e$message, '\n')
    cat('Error details:', toString(e), '\n')
    return(FALSE)
  })
}

# Function to generate sample data
generate_sample_data <- function() {
  cat('\n=== Generating Sample Data ===\n')
  
  # Create sample dataset
  set.seed(123)
  sample_data <- data.frame(
    id = 1:1000,
    value = rnorm(1000, mean = 100, sd = 15),
    category = sample(c('A', 'B', 'C'), 1000, replace = TRUE),
    timestamp = Sys.time() + runif(1000, -3600, 3600)
  )
  
  # Save to NFS (if accessible)
  nfs_file <- '/home/vagrant/shared/data/sample_data.Rdata'
  if (dir.exists(dirname(nfs_file))) {
    save(sample_data, file = nfs_file)
    cat('Data saved to NFS:', nfs_file, '\n')
  }
  
  # Save to MongoDB
  tryCatch({
    # Use same node detection logic as in demonstrate_nosql_solution
    node_info <- if (nchar(Sys.getenv('SLURM_JOB_NODELIST')) > 0) {
      Sys.getenv('SLURM_JOB_NODELIST')
    } else {
      Sys.info()['nodename']
    }
    
    if (grepl('compute-node-[3-4]', node_info)) {
      mongo_host <- 'nosql-node-2:27017'
    } else {
      mongo_host <- 'nosql-node-1:27017'
    }
    
    cat('Saving to MongoDB at:', mongo_host, '\n')
    con <- mongo(collection = 'sample_data', db = 'burst_a_flat', url = paste0('mongodb://', mongo_host))
    con$insert(sample_data)
    con$disconnect()
    cat('Data saved to MongoDB at:', mongo_host, '\n')
  }, error = function(e) {
    cat('ERROR: Failed to save to MongoDB:', e$message, '\n')
    cat('Error details:', toString(e), '\n')
  })
  
  return(sample_data)
}

# Main execution
cat('R Workload Demonstration Started\n')

# Use consistent node detection
node_info <- if (nchar(Sys.getenv('SLURM_JOB_NODELIST')) > 0) {
  Sys.getenv('SLURM_JOB_NODELIST')
} else {
  Sys.info()['nodename']
}

cat('Node:', node_info, '\n')
cat('Network:', ifelse(grepl('compute-node-[3-4]', node_info), 'Network 2 (Cloud)', 'Network 1 (On-Premises)'), '\n\n')

# Generate sample data first
sample_data <- generate_sample_data()

# Try traditional storage access
traditional_success <- demonstrate_traditional_failure()

# Try NoSQL solution
nosql_success <- demonstrate_nosql_solution()

# Summary
cat('\n=== Summary ===\n')
cat('Traditional Storage (NFS):', ifelse(traditional_success, 'SUCCESS', 'FAILURE'), '\n')
cat('NoSQL Database (MongoDB):', ifelse(nosql_success, 'SUCCESS', 'FAILURE'), '\n')

if (!traditional_success && nosql_success) {
  cat('\n✅ CLOUD BURST SCENARIO DEMONSTRATED:\n')
  cat('   Traditional shared storage failed, but NoSQL database provided the solution!\n')
  cat('   This shows how cloud burst scenarios can be handled with distributed databases.\n')
} else if (traditional_success && nosql_success) {
  cat('\n✅ DUAL ACCESS SCENARIO:\n')
  cat('   Both traditional and NoSQL access methods work.\n')
  cat('   This demonstrates hybrid cloud capabilities.\n')
} else {
  cat('\n❌ CONFIGURATION ISSUE:\n')
  cat('   Some components may not be properly configured.\n')
}

cat('\nDemonstration completed at:', Sys.time(), '\n')
"

echo "R Workload Demonstration completed!"
echo "Check results in /home/vagrant/shared/results/"
