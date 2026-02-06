#!/bin/bash
# stops on errors
# set -e

# stops on hidden errors (more robust)
set -euo pipefail 

echo "1. Update system and install prerequisites"
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gnupg


echo "2. Ensure keyrings directory exists and add Kubernetes GPG key"
sudo mkdir -p /etc/apt/keyrings 
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key \
  | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "3. Add Kubernetes APT repository"
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" \
| sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

echo "4. Update system again"
sudo apt update

echo "5. Install Kubernetes components"
sudo apt install -y kubelet kubeadm kubectl

echo "6. Hold version (VERY IMPORTANT), never update kubelet, kubeadm, kubectl automatically"
sudo apt-mark hold kubelet kubeadm kubectl

echo "7. Verify installation"
kubeadm version
kubectl version --client
kubelet --version

echo "🎉 Kubernetes components installed successfully!"