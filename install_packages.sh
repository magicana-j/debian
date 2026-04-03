#!/bin/bash

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo or as root."
  exit 1
fi

# Check if packages.txt exists
if [ ! -f "packages.txt" ]; then
  echo "Error: packages.txt not found."
  exit 1
fi

echo "Updating package list..."
apt-get update

# Read packages.txt line by line
while IFS= read -r package || [ -n "$package" ]; do
  # Skip empty lines and comments
  if [[ -z "$package" || "$package" =~ ^# ]]; then
    continue
  fi

  echo "Attempting to install: $package"
  
  # Install the package. If it fails, it moves to the next one.
  apt-get install -y "$package"
  
  if [ $? -eq 0 ]; then
    echo "Successfully installed: $package"
  else
    echo "Warning: Could not install $package. Skipping..."
  fi
done < packages.txt

echo "Running post-installation tasks..."

# Generate fastfetch config
if command -v fastfetch >/dev/null 2>&1; then
  fastfetch --gen-config
else
  echo "Note: fastfetch is not installed. Skipping config generation."
fi

# Force update user directories to English
# Note: This affects the home directory of the user running the script
LANG=C xdg-user-dirs-update --force

echo "All processes completed."
