#!/bin/bash

# Setup R Environment on Host OS
# This script sets up the same R environment on the host OS as on the compute nodes
# Based on the configuration in inventory/group_vars/all/r_packages.yml

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on supported OS
check_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt &> /dev/null; then
            print_status "Detected Ubuntu/Debian system"
            PACKAGE_MANAGER="apt"
        elif command -v yum &> /dev/null; then
            print_error "This script is designed for Ubuntu/Debian systems with apt"
            print_error "For RHEL/CentOS systems, please use the Ansible playbook instead"
            exit 1
        else
            print_error "Unsupported Linux distribution"
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        print_warning "macOS detected - this script is designed for Linux"
        print_warning "Please install R via Homebrew: brew install r"
        exit 1
    else
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

# Update package cache
update_packages() {
    print_status "Updating package cache..."
    sudo apt update
    print_success "Package cache updated"
}

# Install system packages
install_system_packages() {
    print_status "Installing R system packages..."
    
    # System packages (from inventory/group_vars/all/r_packages.yml)
    local packages=(
        "r-base"
        "r-base-dev"
        "r-cran-dplyr"
        "r-cran-ggplot2"
        "r-cran-data.table"
        "r-cran-jsonlite"
        "r-cran-httr"
        "r-cran-rmarkdown"
        "r-cran-knitr"
        "r-cran-shiny"
        "r-cran-plotly"
        "r-cran-lubridate"
        "r-cran-stringr"
        "r-cran-readr"
        "r-cran-tidyr"
        "r-cran-purrr"
        "r-cran-magrittr"
        "r-cran-glue"
        "r-cran-scales"
        "r-cran-viridis"
    )
    
    # Install packages
    for package in "${packages[@]}"; do
        if dpkg -l | grep -q "^ii  $package "; then
            print_status "$package is already installed"
        else
            print_status "Installing $package..."
            sudo apt install -y "$package"
        fi
    done
    
    print_success "System packages installed"
}

# Install R packages via CRAN (in user home)
install_r_packages() {
    print_status "Installing R packages from CRAN (in user home)..."
    
    # R packages (from inventory/group_vars/all/r_packages.yml)
    local r_packages=(
        "mongolite"
        "DBI"
        "RSQLite"
        "RMySQL"
        "RPostgreSQL"
        "odbc"
        "pool"
        "config"
        "yaml"
        "xml2"
        "curl"
        "openssl"
        "digest"
        "base64enc"
        "Rcpp"
        "RcppArmadillo"
        "RcppEigen"
        "Matrix"
        "lattice"
        "mgcv"
        "nlme"
        "survival"
        "MASS"
        "cluster"
        "foreign"
        "nnet"
        "spatial"
        "rpart"
        "class"
        "boot"
        "splines"
        "stats"
        "utils"
        "grDevices"
        "graphics"
        "methods"
        "datasets"
        "tools"
        "parallel"
        "compiler"
        "grid"
        "tcltk"
        "KernSmooth"
    )
    
    # Create R script for package installation
    local r_script=$(mktemp)
    cat > "$r_script" << EOF
# Install R packages in user home directory
packages <- c($(printf '"%s",' "${r_packages[@]}" | sed 's/,$//'))
cat("Installing", length(packages), "R packages in user home...\n")

# Set user library path
user_lib <- Sys.getenv("R_LIBS_USER")
if (user_lib == "") {
  user_lib <- file.path(Sys.getenv("HOME"), "R", "x86_64-pc-linux-gnu-library", R.version$major, ".", R.version$minor)
}
dir.create(user_lib, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(user_lib, .libPaths()))

cat("Installing packages to:", user_lib, "\n")

# Install packages with error handling
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("Installing", pkg, "...\n")
    install.packages(pkg, repos = "https://cran.rstudio.com/", dependencies = TRUE, type = "source", lib = user_lib)
  } else {
    cat(pkg, "is already installed\n")
  }
}

cat("R package installation complete!\n")
EOF
    
    # Run R script
    R --slave < "$r_script"
    rm "$r_script"
    
    print_success "R packages installed in user home"
}

# Verify installation
verify_installation() {
    print_status "Verifying R installation..."
    
    # Check R version
    local r_version=$(R --version | head -n 1)
    print_success "R version: $r_version"
    
    # Test key packages
    local test_script=$(mktemp)
    cat > "$test_script" << 'EOF'
# Test key packages
test_packages <- c("mongolite", "DBI", "dplyr", "ggplot2", "data.table")

# Set user library path
user_lib <- Sys.getenv("R_LIBS_USER")
if (user_lib == "") {
  user_lib <- file.path(Sys.getenv("HOME"), "R", "x86_64-pc-linux-gnu-library", R.version$major, ".", R.version$minor)
}
.libPaths(c(user_lib, .libPaths()))

cat("Using R library paths:\n")
for (lib in .libPaths()) {
  cat("  -", lib, "\n")
}

for (pkg in test_packages) {
  if (require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("✓", pkg, "loaded successfully\n")
  } else {
    cat("✗", pkg, "failed to load\n")
  }
}
EOF
    
    R --slave < "$test_script"
    rm "$test_script"
    
    print_success "R environment verification complete"
}

# Generate sample data (optional)
generate_sample_data() {
    if [[ "$1" == "--with-sample-data" ]]; then
        print_status "Generating sample data..."
        if [[ -f "scripts/generate_sample_data.R" ]]; then
            Rscript scripts/generate_sample_data.R
            print_success "Sample data generated"
        else
            print_warning "Sample data script not found, skipping..."
        fi
    fi
}

# Main function
main() {
    print_status "Setting up R environment on host OS..."
    print_status "This will install the same R packages as the compute nodes"
    
    # Check OS
    check_os
    
    # Update packages
    update_packages
    
    # Install system packages
    install_system_packages
    
    # Install R packages
    install_r_packages
    
    # Verify installation
    verify_installation
    
    # Generate sample data if requested
    generate_sample_data "$1"
    
    print_success "R environment setup complete!"
    print_status "You can now use R with the same packages as the compute nodes"
    print_status "Try: R --slave -e 'library(mongolite); library(dplyr)'"
}

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Setup R environment on host OS to match compute nodes"
    echo ""
    echo "Options:"
    echo "  --with-sample-data    Also generate sample data files"
    echo "  --help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                   # Basic R environment setup"
    echo "  $0 --with-sample-data # Setup with sample data"
}

# Parse command line arguments
case "${1:-}" in
    --help|-h)
        show_help
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac