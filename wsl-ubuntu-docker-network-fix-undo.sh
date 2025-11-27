#!/bin/bash

set -e

USER_NAME="YOURUSER"
DOCKER_DATA="/home/$USER_NAME/docker-data"

echo "=== WSL + Docker Undo Script ==="
echo "Running as: $(whoami)"
echo

# ------------------------------
# 1. Restore WSL resolv.conf default
# ------------------------------

echo "[1/5] Restoring default /etc/resolv.conf..."

# Remove immutable flag if set
sudo chattr -i /etc/resolv.conf 2>/dev/null || true

# Remove custom resolv.conf
sudo rm -f /etc/resolv.conf

# Allow WSL to auto-generate DNS again
sudo sed -i 's/^generateResolvConf=false$/generateResolvConf=true/' /etc/wsl.conf

echo "WSL DNS auto-generation restored."
echo

# ------------------------------
# 2. Remove custom Docker daemon.json
# ------------------------------

echo "[2/5] Removing /etc/docker/daemon.json..."

sudo rm -f /etc/docker/daemon.json

echo "Custom Docker daemon settings removed."
echo

# ------------------------------
# 3. Optional: Remove custom Docker data folder
# ------------------------------

echo "[3/5] Optional: Remove Docker data folder: $DOCKER_DATA ?"

read -p "Type YES to delete, or anything else to skip: " CONFIRM

if [ "$CONFIRM" = "YES" ]; then
    sudo rm -rf "$DOCKER_DATA"
    echo "Docker custom data folder removed."
else
    echo "Skipped removing $DOCKER_DATA"
fi

echo

# ------------------------------
# 4. Restart Docker service
# ------------------------------

echo "[4/5] Restarting Docker service..."

sudo service docker stop || true
sudo service docker start || true

echo "Docker service restarted."
echo

# ------------------------------
# 5. Instruct user to restart WSL
# ------------------------------

echo "=== FINAL STEP ==="
echo "You must now run the following in PowerShell:"
echo
echo "  wsl --shutdown"
echo
echo "Then re-open Ubuntu to apply all changes."
echo
echo "WSL + Docker undo completed successfully!"