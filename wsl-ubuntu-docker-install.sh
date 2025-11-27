#!/bin/bash
set -e

echo "🐳 Starting Docker setup for WSL..."

# --------------------------------------------------
# 1. Remove old Docker versions
# --------------------------------------------------
echo "Removing old Docker packages (if any)..."
sudo apt remove -y docker docker-engine docker.io containerd runc || true

# --------------------------------------------------
# 2. Install Docker APT repository
# --------------------------------------------------
echo "Adding Docker repository..."
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# --------------------------------------------------
# 3. Install Docker Engine
# --------------------------------------------------
echo "Installing Docker Engine..."
sudo apt update
sudo apt install -y \
  docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

# --------------------------------------------------
# 4. Enable Docker (requires systemd)
# --------------------------------------------------
echo "Enabling Docker service..."
sudo systemctl enable --now docker || {
  echo "⚠️  Systemd is not enabled. Docker will not auto-start until systemd is enabled in WSL.";
}

# --------------------------------------------------
# 5. Add user to docker group
# --------------------------------------------------
echo "Adding user '$USER' to docker group..."
sudo usermod -aG docker "$USER"

# --------------------------------------------------
# 6. Create WSL config enabling systemd
# --------------------------------------------------
echo "Creating /etc/wsl.conf..."
sudo tee /etc/wsl.conf > /dev/null << 'EOF'
[boot]
systemd=true
[automount]
enabled=true
options=metadata,umask=22,fmask=11
mountFsTab=false
EOF

echo "🎉 Docker install finished!"
echo "➡️  Please **close and reopen your WSL terminal**, OR run:"
echo "    newgrp docker"
echo "to activate Docker group access."
echo "➡️ If systemd wasn’t active, run: wsl --shutdown"
echo "Then restart WSL."