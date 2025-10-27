#!/bin/bash
#SBATCH --job-name=r_workload_demo
#SBATCH --output=/home/vagrant/shared/results/r_workload_%A_%a.out
#SBATCH --error=/home/vagrant/shared/results/r_workload_%A_%a.err
#SBATCH --time=00:10:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=1G
#SBATCH --array=1-4

# R Workload Demonstration Script
# This script demonstrates the cloud burst scenario where traditional
# shared storage fails but NoSQL database provides the solution

echo "Starting R Workload Demonstration..."
echo "Job ID: $SLURM_JOB_ID"
echo "Array Task ID: $SLURM_ARRAY_TASK_ID"
echo "Node: $SLURM_JOB_NODELIST"
echo "Date: $(date)"

# Debug information
echo "=== Debug Information ==="
echo "Current user: $(whoami)"
echo "Current directory: $(pwd)"
echo "Node hostname: $(hostname)"
echo "SLURM_JOB_ID: $SLURM_JOB_ID"
echo "SLURM_ARRAY_TASK_ID: $SLURM_ARRAY_TASK_ID"
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
tryCatch({
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
}, error = function(e) {
  cat('ERROR: Package installation failed:', e$message, '\n')
  quit(status = 1)
})
"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install R packages"
    exit 1
fi

echo ""

# Run the R demonstration
Rscript /home/vagrant/shared/scripts/r_workload_demo.R

echo "R Workload Demonstration completed!"
echo "Check results in /home/vagrant/shared/results/"
