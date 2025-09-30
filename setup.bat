@echo off
REM Burst-A-Flat Setup Script for Windows
REM Allows users to choose between VirtualBox and vSphere

echo === Burst-A-Flat Setup ===
echo Choose your virtualization provider:
echo 1^) VirtualBox (default^)
echo 2^) vSphere
echo 3^) Exit
echo.

set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" (
    echo Setting up for VirtualBox...
    ruby scripts/generate_vagrantfile.rb virtualbox
    echo ✅ VirtualBox Vagrantfile generated
) else if "%choice%"=="2" (
    echo Setting up for vSphere...
    ruby scripts/generate_vagrantfile.rb vsphere
    echo ✅ vSphere Vagrantfile generated
) else if "%choice%"=="3" (
    echo Exiting...
    exit /b 0
) else (
    echo Invalid choice. Using VirtualBox as default...
    ruby scripts/generate_vagrantfile.rb virtualbox
    echo ✅ VirtualBox Vagrantfile generated
)

echo.
echo === Setup Complete ===
echo Your Vagrantfile has been generated for your chosen provider.
echo.
echo Next steps:
echo 1. Make sure your chosen virtualization software is installed
echo 2. Run: vagrant up
echo 3. Configure the cluster: ansible-playbook -i inventory/hosts playbooks/site.yml
echo.
echo For VirtualBox users:
echo   - VirtualBox must be installed
echo   - VirtualBox Extension Pack recommended
echo.
echo For vSphere users:
echo   - vSphere must be installed
echo   - Vagrant vSphere plugin: vagrant plugin install vagrant-vsphere
