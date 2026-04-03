#!/bin/bash

# Define the security packages
# usbguard: USB device authorization policy framework
# rkhunter / chkrootkit: Rootkit scanning tools
# firejail: SUID sandbox program to isolate applications
PACKAGES=(
#    "usbguard"
    "rkhunter"
    "chkrootkit"
    "firejail"
    "firejail-profiles"
)

FAILED_PACKAGES=()

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root or with sudo."
    exit 1
fi

echo "Updating package lists..."
apt-get update -y -q

echo "Starting the installation of security tools..."

for PKG in "${PACKAGES[@]}"; do
    echo "------------------------------------------------"
    echo "Installing: $PKG"
    
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q "$PKG"
    
    if [ $? -ne 0 ]; then
        echo "WARNING: Failed to install $PKG."
        FAILED_PACKAGES+=("$PKG")
    fi
done

echo "------------------------------------------------"
echo "Configuring security tools..."

# 1. USBGuard Configuration
# Generate an initial policy based on currently connected devices to avoid locking out the keyboard/mouse
#if command -v usbguard >/dev/null; then
#    echo "Generating USBGuard policy based on current devices..."
#    usbguard generate-policy > /etc/usbguard/rules.conf
#    systemctl enable usbguard
#    systemctl start usbguard
#    echo "SUCCESS: USBGuard is active. New USB devices will be blocked by default."
#fi

# 2. Rootkit Checkers Initial Setup
if command -v rkhunter >/dev/null; then
    echo "Updating rkhunter properties database..."
    rkhunter --propupd
fi

# Final Results Summary
echo "================================================"
echo "Security tool installation finished."

if [ ${#FAILED_PACKAGES[@]} -eq 0 ]; then
    echo "SUCCESS: All security packages were installed and configured."
else
    echo "The following packages could not be installed:"
    for FAILED in "${FAILED_PACKAGES[@]}"; do
        echo " - $FAILED"
    done
fi

echo "================================================"
echo "IMPORTANT NOTES:"
echo "1. USBGuard: Use 'usbguard list-devices' and 'usbguard allow-device <id>' to manage new USBs."
echo "2. Rootkit: Run 'sudo rkhunter --check' or 'sudo chkrootkit' manually to scan your system."
echo "3. Firejail: Use 'firejail <application>' to run apps in a sandbox (e.g., firejail firefox)."
