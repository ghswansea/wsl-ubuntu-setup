#!/bin/bash

set -e

USER_NAME="YOURUSER"
DOCKER_DATA="/home/$USER_NAME/docker-data"

echo "=== WSL + Docker Auto Fix Script ==="
echo "Running as: $(whoami)"
echo

# ------------------------------
# 1. Fix WSL DNS (permanent)
# ------------------------------

echo "[1/6] Configuring WSL DNS..."

echo "Appending network settings to /etc/wsl.conf..."
sudo tee -a /etc/wsl.conf > /dev/null << 'EOF'
[network]
generateResolvConf=false
EOF

# Create permanent resolv.conf
sudo rm -f /etc/resolv.conf
# Stop WSL from overwriting resolv.conf
sudo tee /etc/resolv.conf >/dev/null <<EOF
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF

# Protect the file
sudo chattr +i /etc/resolv.conf

echo "DNS fixed using Cloudflare + Google."
echo

# ------------------------------
# 2. Apply recommended Docker daemon.json
# ------------------------------

echo "[2/6] Updating /etc/docker/daemon.json..."

sudo mkdir -p /etc/docker

sudo tee /etc/docker/daemon.json >/dev/null <<EOF
{
  "dns": ["1.1.1.1", "8.8.8.8"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "ipv6": false,
  "experimental": true,
  "data-root": "$DOCKER_DATA"
}
EOF

echo "Docker configuration updated."
echo

# ------------------------------
# 3. Create Docker data directory
# ------------------------------

echo "[3/6] Creating Docker data directory..."

sudo mkdir -p "$DOCKER_DATA"
sudo chown -R $USER_NAME:$USER_NAME "$DOCKER_DATA"

echo "Docker data directory is ready."
echo

# ------------------------------
# 4. Clean previous Docker storage (Optional / safe)
# ------------------------------

echo "[4/6] Cleaning old Docker data (safe skip if doesn't exist)..."
sudo rm -rf /var/lib/docker || true
sudo rm -rf /var/lib/containerd || true

echo "Old Docker data removed if it existed."
echo

# ------------------------------
# 5. Restart Docker
# ------------------------------

echo "[5/6] Restarting Docker service..."
sudo service docker stop || true
sudo service docker start || true

echo "Docker restarted."
echo

# ------------------------------
# 6. Instruct user to restart WSL
# ------------------------------

echo "=== IMPORTANT FINAL STEP ==="
echo "You must now run the following in PowerShell:"
echo
echo "  wsl --shutdown"
echo
echo "Close and re-open Ubuntu after that."
echo
echo "WSL + Docker auto-fix completed successfully!"