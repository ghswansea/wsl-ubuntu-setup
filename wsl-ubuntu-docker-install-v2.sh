#!/bin/bash
set -e

echo "🐳 Starting Docker setup for WSL..."

# --------------------------------------------------
# 1. Remove old Docker versions (if they exist)
# --------------------------------------------------
if dpkg -l | grep -qE "(docker.io|docker-ce|docker-ce-cli|containerd)"; then
  echo "Removing old Docker versions..."
  sudo apt remove -y docker docker-engine docker.io containerd runc || true
else
  echo "No old Docker packages found."
fi

# --------------------------------------------------
# 2. Ensure required packages are installed (idempotent)
# --------------------------------------------------
echo "Installing dependencies..."
sudo apt update

DEPENDENCIES=(ca-certificates curl gnupg lsb-release)

for pkg in "${DEPENDENCIES[@]}"; do
  if dpkg -l | grep -q "^ii  $pkg "; then
    echo "✔ $pkg already installed"
  else
    echo "📦 Installing $pkg..."
    sudo apt install -y "$pkg"
  fi
done

# --------------------------------------------------
# 3. Install Docker repository (only if missing)
# --------------------------------------------------
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  echo "Adding Docker GPG key..."
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
else
  echo "✔ Docker GPG key already exists"
fi

if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
  echo "Adding Docker APT repository..."
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
else
  echo "✔ Docker repository already exists"
fi

# --------------------------------------------------
# 4. Install Docker Engine (only if not installed)
# --------------------------------------------------
if command -v docker >/dev/null 2>&1; then
  echo "✔ Docker already installed"
else
  echo "Installing Docker Engine..."
  sudo apt update
  sudo apt install -y \
    docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin
fi

# --------------------------------------------------
# 5. Enable Docker service (systemd only)
# --------------------------------------------------
if systemctl is-enabled docker >/dev/null 2>&1; then
  echo "✔ Docker service already enabled"
else
  echo "Enabling Docker service..."
  sudo systemctl enable --now docker || \
    echo "⚠️  Could not enable service (systemd may not be active yet)"
fi

# --------------------------------------------------
# 6. Add user to docker group
# --------------------------------------------------
if groups $USER | grep -q docker; then
  echo "✔ User '$USER' already in docker group"
else
  echo "Adding user '$USER' to docker group..."
  sudo usermod -aG docker "$USER"
fi

# --------------------------------------------------
# 7. Ensure /etc/wsl.conf exists with systemd=true
# --------------------------------------------------
WSL_CONF_CONTENT="[boot]
systemd=true
[automount]
enabled=true
options=metadata,umask=22,fmask=11
mountFsTab=false
"

if [ -f /etc/wsl.conf ] && grep -q "systemd=true" /etc/wsl.conf; then
  echo "✔ /etc/wsl.conf already configured for systemd"
else
  echo "Configuring /etc/wsl.conf..."
  echo "$WSL_CONF_CONTENT" | sudo tee /etc/wsl.conf > /dev/null
fi

echo "🎉 Docker installation complete!"
echo "➡️ Please close WSL and run:  wsl --shutdown"
echo "➡️ Then restart your terminal."
echo "➡️ Or activate docker group now with: newgrp docker"