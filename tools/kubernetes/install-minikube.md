# 1. check docker
docker ps
# 2. install minikube 
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
verify:
minikube version
# 3. start minikube using docker driver (important)
minikube start --driver=docker
# 4. verify kubernetes cluster
kubectl get nodes
expected:
NAME       STATUS   ROLES           AGE    VERSION
minikube   Ready    control-plane   100s   v1.35.0
