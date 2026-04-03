#!/bin/bash

# Define the development environment packages
# These names are consistent with the Debian 13 (Trixie) repository structure
PACKAGES=(
    "curl"
    "vim"
    "neovim"
    "build-essential"
    "gcc"
    "clang"
    "cmake"
    "python3-pip"
    "python3-venv"
    "python3-poetry"
    "pyenv"
    "rustc"
    "cargo"
    "golang-go"
    "geany"
    "podman"
    "podman-compose"
)

FAILED_PACKAGES=()

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root or with sudo."
    exit 1
fi

echo "Updating package lists using apt-get..."
# -y: Assume yes, -q: Quiet
apt-get update -y -q

echo "Starting the installation of development tools..."

# DEBIAN_FRONTEND=noninteractive prevents post-install configuration screens from popping up
for PKG in "${PACKAGES[@]}"; do
    echo "------------------------------------------------"
    echo "Installing: $PKG"
    
    # Using apt-get for better script stability
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q "$PKG"
    
    # Capture exit status of the last command
    if [ $? -ne 0 ]; then
        echo "WARNING: Failed to install $PKG. Skipping to next..."
        FAILED_PACKAGES+=("$PKG")
    fi
done

# Final Results Summary
echo "================================================"
echo "Installation process finished."

if [ ${#FAILED_PACKAGES[@]} -eq 0 ]; then
    echo "SUCCESS: All packages were installed successfully."
else
    echo "The following packages could not be installed:"
    for FAILED in "${FAILED_PACKAGES[@]}"; do
        echo " - $FAILED"
    done
    echo "Tip: Check your /etc/apt/sources.list or network connection."
fi
