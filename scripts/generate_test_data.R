#!/usr/bin/env Rscript
# Generate test data for the Slurm cluster demonstration

# Load required libraries
library(mongolite)
library(dplyr)

# Function to generate sample dataset
generate_sample_data <- function(n_records = 10000) {
  cat("Generating", n_records, "sample records...\n")
  
  set.seed(42)
  data <- data.frame(
    id = 1:n_records,
    value = rnorm(n_records, mean = 100, sd = 15),
    category = sample(c('A', 'B', 'C', 'D'), n_records, replace = TRUE),
    timestamp = Sys.time() + runif(n_records, -86400, 86400),  # Within last 24 hours
    region = sample(c('North', 'South', 'East', 'West'), n_records, replace = TRUE),
    score = runif(n_records, 0, 100)
  )
  
  return(data)
}

# Function to save data to NFS
save_to_nfs <- function(data, filename = "sample_data.Rdata") {
  nfs_path <- paste0("/home/vagrant/shared/data/", filename)
  
  # Create directory if it doesn't exist
  dir.create(dirname(nfs_path), recursive = TRUE, showWarnings = FALSE)
  
  # Save data
  save(data, file = nfs_path)
  cat("Data saved to NFS:", nfs_path, "\n")
}

# Function to save data to MongoDB
save_to_mongodb <- function(data, host = "nosql-node-1:27017") {
  tryCatch({
    # Connect to MongoDB
    con <- mongo(collection = 'sample_data', db = 'burst_a_flat', url = paste0('mongodb://', host))
    
    # Clear existing data
    con$drop()
    
    # Insert new data
    con$insert(data)
    
    # Verify insertion
    count <- con$count()
    cat("Data saved to MongoDB at", host, "- Records:", count, "\n")
    
    con$disconnect()
    return(TRUE)
  }, error = function(e) {
    cat("ERROR: Failed to save to MongoDB:", e$message, "\n")
    return(FALSE)
  })
}

# Main execution
cat("=== Burst-A-Flat Test Data Generator ===\n")
cat("Date:", Sys.time(), "\n\n")

# Generate sample data
sample_data <- generate_sample_data(10000)

# Save to NFS (if accessible)
cat("Saving to NFS...\n")
save_to_nfs(sample_data)

# Save to MongoDB primary
cat("Saving to MongoDB primary...\n")
save_to_mongodb(sample_data, "nosql-node-1:27017")

# Save to MongoDB replica
cat("Saving to MongoDB replica...\n")
save_to_mongodb(sample_data, "nosql-node-2:27017")

# Generate summary statistics
cat("\n=== Data Summary ===\n")
cat("Total records:", nrow(sample_data), "\n")
cat("Categories:", unique(sample_data$category), "\n")
cat("Regions:", unique(sample_data$region), "\n")
cat("Value range:", range(sample_data$value), "\n")
cat("Score range:", range(sample_data$score), "\n")

# Create some additional test files
cat("\n=== Creating Additional Test Files ===\n")

# Create a smaller dataset for quick testing
small_data <- sample_data[1:1000, ]
save_to_nfs(small_data, "small_sample_data.Rdata")

# Create a CSV version
csv_path <- "/home/vagrant/shared/data/sample_data.csv"
write.csv(sample_data, csv_path, row.names = FALSE)
cat("CSV data saved to:", csv_path, "\n")

# Create a JSON version
json_path <- "/home/vagrant/shared/data/sample_data.json"
jsonlite::write_json(sample_data, json_path, pretty = TRUE)
cat("JSON data saved to:", json_path, "\n")

cat("\n=== Test Data Generation Complete ===\n")
cat("Files created:\n")
cat("  - /home/vagrant/shared/data/sample_data.Rdata\n")
cat("  - /home/vagrant/shared/data/small_sample_data.Rdata\n")
cat("  - /home/vagrant/shared/data/sample_data.csv\n")
cat("  - /home/vagrant/shared/data/sample_data.json\n")
cat("  - MongoDB: burst_a_flat.sample_data\n")
