@echo off
REM Deployment script for Burst-A-Flat Slurm cluster (Windows)

echo === Burst-A-Flat Slurm Cluster Deployment ===
echo Date: %date% %time%
echo.

REM Check prerequisites
echo Checking prerequisites...

REM Check if Vagrant is installed
vagrant --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Vagrant is not installed. Please install Vagrant first.
    exit /b 1
)

REM Check if Ansible is installed
ansible --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Ansible is not installed. Please install Ansible first.
    exit /b 1
)

REM Check if VirtualBox is installed
VBoxManage --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: VirtualBox is not installed. Please install VirtualBox first.
    exit /b 1
)

echo ✅ All prerequisites found
echo.

REM Create necessary directories
echo Creating directories...
if not exist data mkdir data
if not exist results mkdir results
if not exist logs mkdir logs
echo ✅ Directories created
echo.

REM Deploy VMs
echo Deploying virtual machines...
echo This may take 10-15 minutes...
vagrant up
echo ✅ Virtual machines deployed
echo.

REM Configure cluster
echo Configuring Slurm cluster...
echo This may take 5-10 minutes...
ansible-playbook -i inventory/hosts playbooks/site.yml
echo ✅ Cluster configured
echo.

REM Generate test data
echo Generating test data...
vagrant ssh controller-node -c "Rscript /home/vagrant/shared/scripts/generate_test_data.R"
echo ✅ Test data generated
echo.

REM Test cluster
echo Testing cluster...
vagrant ssh login-node -c "sinfo"
echo ✅ Cluster test completed
echo.

echo === Deployment Complete ===
echo.
echo To use the cluster:
echo 1. Login: vagrant ssh login-node
echo 2. Check status: sinfo
echo 3. Submit job: sbatch /home/vagrant/shared/scripts/r_workload_demo.sh
echo 4. Monitor jobs: squeue
echo.
echo Cluster nodes:
echo   - Login: login-node
echo   - Controller: controller-node
echo   - Compute: compute-node-1, compute-node-2, compute-node-3, compute-node-4
echo   - Database: slurmdb-node
echo   - NoSQL: nosql-node-1, nosql-node-2
echo.
echo For more information, see README.md
