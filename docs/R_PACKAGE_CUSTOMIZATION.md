# R Package Customization Guide

This guide explains how to customize the R environment for your specific research needs.

## Overview

The R environment is configured through Ansible variables in `inventory/group_vars/all/r_packages.yml`. This file contains two main sections:

1. **System packages** (`r_system_packages`) - Installed via `apt`
2. **R packages** (`r_cran_packages`) - Installed via R's `install.packages()`

## Customizing R Packages

### 1. System Packages (apt)

These are R packages available in the Ubuntu repositories:

```yaml
r_system_packages:
  - r-base
  - r-base-dev
  - r-cran-dplyr
  - r-cran-ggplot2
  - r-cran-data.table
  # Add your packages here
  - r-cran-your-package
```

**Note:** Not all R packages are available as system packages. Check availability with:
```bash
apt search r-cran-your-package
```

### 2. R Packages (CRAN)

These are installed directly from CRAN using R's package manager:

```yaml
r_cran_packages:
  - mongolite
  - DBI
  - RSQLite
  # Add your packages here
  - your-package-name
```

### 3. CRAN Repository

You can change the CRAN repository URL:

```yaml
r_cran_repo: "https://cran.rstudio.com/"
# Or use a local mirror:
# r_cran_repo: "https://cran.your-university.edu/"
```

## Common Research Packages

### Data Science & Statistics
```yaml
r_cran_packages:
  - tidyverse
  - caret
  - randomForest
  - glmnet
  - survival
  - lme4
  - nlme
  - mgcv
```

### Machine Learning
```yaml
r_cran_packages:
  - keras
  - tensorflow
  - xgboost
  - lightgbm
  - h2o
  - mlr3
```

### Bioinformatics
```yaml
r_cran_packages:
  - BiocManager
  - DESeq2
  - edgeR
  - limma
  - clusterProfiler
```

### Economics & Finance
```yaml
r_cran_packages:
  - quantmod
  - PerformanceAnalytics
  - PortfolioAnalytics
  - rugarch
  - vars
  - urca
```

### Social Sciences
```yaml
r_cran_packages:
  - survey
  - srvyr
  - lavaan
  - semTools
  - psych
  - car
```

## Installation Process

1. **Edit the configuration:**
   ```bash
   vim inventory/group_vars/all/r_packages.yml
   ```

2. **Run the playbook:**
   ```bash
   ansible-playbook playbooks/site.yml --limit slurm_computes,login-node
   ```

3. **Verify installation:**
   ```bash
   vagrant ssh login-node
   R --slave -e "library(your-package); packageVersion('your-package')"
   ```

## Troubleshooting

### Package Installation Failures

If a package fails to install:

1. **Check if it's available as a system package:**
   ```bash
   apt search r-cran-your-package
   ```

2. **Move it to the appropriate list** (system vs. CRAN)

3. **Check for dependencies:**
   ```bash
   R --slave -e "install.packages('your-package', dependencies=TRUE)"
   ```

### Memory Issues

For large packages, you may need to increase memory limits:

```yaml
r_install_options:
  repos: "{{ r_cran_repo }}"
  dependencies: true
  upgrade: "never"
  type: "source"
  # Add memory options
  INSTALL_opts: "--no-multiarch"
```

## Best Practices

1. **Start with essential packages** and add more as needed
2. **Use system packages when available** (faster installation)
3. **Group related packages** for easier management
4. **Test installations** on a single node first
5. **Document your customizations** for team members

## Example: Complete Custom Configuration

```yaml
# System packages (fast installation)
r_system_packages:
  - r-base
  - r-base-dev
  - r-cran-dplyr
  - r-cran-ggplot2
  - r-cran-data.table
  - r-cran-rmarkdown
  - r-cran-shiny

# CRAN packages (comprehensive data science stack)
r_cran_packages:
  - mongolite
  - DBI
  - RSQLite
  - tidyverse
  - caret
  - randomForest
  - xgboost
  - keras
  - tensorflow
  - quantmod
  - PerformanceAnalytics
  - survey
  - lavaan
  - psych

# Repository configuration
r_cran_repo: "https://cran.rstudio.com/"
```
