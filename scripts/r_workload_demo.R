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
    
    # Connect to MongoDB with array task-specific collection
    array_task_id <- as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID', '1'))
    collection_name <- paste0('sample_data_task_', array_task_id)
    cat('Using MongoDB collection:', collection_name, '\n')
    
    con <- mongo(collection = collection_name, db = 'burst_a_flat', url = paste0('mongodb://', mongo_host))
    
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
    tryCatch({
      cat('ERROR: Failed to connect to MongoDB:', e$message, '\n')
      cat('Error details:', as.character(e), '\n')
    }, error = function(e2) {
      cat('ERROR: Failed to connect to MongoDB (error in error handling)\n')
      cat('Original error type:', class(e), '\n')
    })
    return(FALSE)
  })
}

# Function to generate sample data
generate_sample_data <- function() {
  cat('\n=== Generating Sample Data ===\n')
  
  # Create sample dataset with array task-specific seed
  array_task_id <- as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID', '1'))
  set.seed(123 + array_task_id)  # Different seed for each array task
  
  cat('Array Task ID:', array_task_id, '\n')
  cat('Using seed:', 123 + array_task_id, '\n')
  
  # Create sample dataset with task-specific data
  sample_data <- data.frame(
    id = 1:1000,
    value = rnorm(1000, mean = 100 + array_task_id * 10, sd = 15),  # Different mean per task
    category = sample(c('A', 'B', 'C'), 1000, replace = TRUE),
    timestamp = Sys.time() + runif(1000, -3600, 3600),
    array_task = rep(array_task_id, 1000)  # Track which array task generated this data
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
    array_task_id <- as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID', '1'))
    collection_name <- paste0('sample_data_task_', array_task_id)
    con <- mongo(collection = collection_name, db = 'burst_a_flat', url = paste0('mongodb://', mongo_host))
    con$insert(sample_data)
    con$disconnect()
    cat('Data saved to MongoDB collection:', collection_name, 'at:', mongo_host, '\n')
  }, error = function(e) {
    tryCatch({
      cat('ERROR: Failed to save to MongoDB:', e$message, '\n')
      cat('Error details:', as.character(e), '\n')
    }, error = function(e2) {
      cat('ERROR: Failed to save to MongoDB (error in error handling)\n')
      cat('Original error type:', class(e), '\n')
    })
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
cat('Array Task ID:', Sys.getenv('SLURM_ARRAY_TASK_ID', '1'), '\n')
cat('Node:', Sys.getenv('SLURM_JOB_NODELIST', 'unknown'), '\n')
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
