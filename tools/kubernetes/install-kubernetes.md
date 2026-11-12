# 1. make sure you’re editing a REAL config
sudo ls -l /etc/containerd/config.toml

# 2. (Re)generate a clean default config (safe)
sudo containerd config default | sudo tee /etc/containerd/config.toml

# 3. reopen it:
sudo nano /etc/containerd/config.toml

# 4. Where SystemdCgroup actually is (containerd ≥ 1.6)
ctrl + W
SystemdCgroup

change SystemdCgroup = false to SystemdCgroup = true

Save and exit:
Ctrl + O → Enter
Ctrl + X

# 1️⃣ Disable swap (MANDATORY)
## check swap status
free -h

## Disable swap (runtime)
sudo swapoff -a

## Disable swap permanently
sudo nano /etc/fstab   => # /swap.img none swap sw 0 0

# 2️⃣ Configure kernel networking (VERY IMPORTANT)
## Load required kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

## Set sysctl parameters
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

## apply
sudo sysctl --system

# 3️⃣ Install container runtime: containerd (REAL WORLD)
## Install containerd
sudo apt update
sudo apt install -y containerd
## Generate default config
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# 4️⃣ Configure cgroup driver (CRITICAL)
Kubelet and container runtime must use the same cgroup driver.
## Edit containerd config
sudo nano /etc/containerd/config.toml
Find:SystemdCgroup = false
Change to:SystemdCgroup = true
Save and exit.
## Restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd
## Verify:
systemctl status containerd

# 5️⃣ Initialize the Kubernetes cluster (NOW you do kubeadm init)
Now your system is ready.
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
⏳ This takes 1–2 minutes.
(explain why 192.168.*** => 192.168.0.0/16 is chosen as the Pod network because it is a private CIDR that does not overlap with existing node or Docker networks, ensuring correct Pod routing.)

When it finishes, it will print IMPORTANT instructions.
Do not skip them.

# 6️⃣ Configure kubectl for your user (MANDATORY)
## Run exactly what kubeadm prints, usually:
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
## now test:
kubectl get nodes
## Expected:
NAME              STATUS     ROLES           AGE   VERSION
DESKTOP-XXXX      NotReady  control-plane   ...

NotReady is NORMAL right now.

# 7️⃣ Install a CNI (network plugin) — REQUIRED
## Without a CNI, pods cannot talk and node stays NotReady.
Use Calico (production-grade)
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

Wait:
    kubectl get pods -n kube-system

When everything is Running, your node becomes Ready.

# 8️⃣ Allow workloads on single-node cluster (WSL2)
In production, control-plane nodes are tainted.
In WSL2, we remove that.

kubectl taint nodes --all node-role.kubernetes.io/control-plane-
## output: node/desktop-3rsu7g0 untainted

# 9️⃣ Verify cluster health (VERY IMPORTANT)
kubectl get nodes
kubectl get pods -A

You should see:
Node = Ready
Core pods running

# 🔟 Test like a real Kubernetes admin
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get pods
kubectl get svc

🎉 You now have a real Kubernetes cluster.

# 🧠 What you just achieved (this is big)

You can now honestly say:

✔ I installed Kubernetes with kubeadm

✔ I configured containerd

✔ I handled cgroups

✔ I installed CNI networking

✔ I run a real cluster

This is real-world Kubernetes admin experience, not toy setup.

# 🏁 Very important mindset

If something breaks, don’t reinstall.
Debug it. That’s how Kubernetes engineers are made.

