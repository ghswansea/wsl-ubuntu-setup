# WSL2 Ubuntu 24.04 DevOps Setup

A fully automated **DevOps-ready development environment** running on **Windows 11 using WSL2 and Ubuntu 24.04**.  
This project installs and configures Docker, AWS CLI, Terraform, and enables **local execution of GitHub Actions** using `act`.

Designed for developers and DevOps engineers who want a **fast, reproducible local CI/CD environment** without relying on cloud runners.

---

## Architecture Overview

```text
Windows 11
 └── WSL2 (Linux Kernel)
      └── Ubuntu 24.04
           ├── Docker Engine
           │    ├── docker0 bridge
           │    └── Container Networking (iptables)
           ├── GitHub Actions Runner (act)
           │    └── CI Containers (ubuntu-latest)
           ├── AWS CLI
           └── Terraform


## 🚀 Features

- Install **Ubuntu 24.04** on **WSL2 (Windows 11)**
- Install and configure **Docker inside WSL2**
- Fix Docker networking and port exposure issues on WSL2
- Install **AWS CLI**
- Install **Terraform**
- Run **GitHub Actions locally** using `act`
- Execute CI jobs such as **test**, **lint**, and **security** locally

---

## 🧰 Tech Stack & Skills

### 🔧 DevOps & Infrastructure
- DevOps
- CI/CD Pipelines
- Infrastructure as Code (IaC)
- GitHub Actions
- Local CI/CD (`act`)

### 🐳 Containers & Virtualization
- Docker
- Container Networking
- WSL2
- Linux Containers

### ☁️ Cloud & Automation
- AWS CLI
- Terraform
- Cloud Automation

### 🐧 Operating Systems & Scripting
- Ubuntu 24.04
- Linux System Administration
- Bash / Shell Scripting
- Windows 11 + WSL Integration

---

## 📋 Prerequisites

- **Windows 11**
- **WSL2 enabled**
- Administrator privileges on Windows
- GitHub Personal Access Token (for `act`)

---

## 🛠️ Installation Steps
1. install ubuntu 24.04 in WSL2 in windows11
2. install docker inside WSL2 ubuntu 24.04
   fix network expose by /etc/docker/daemon.json, /etc/wsl.conf, /etc/resolve.conf
3. install awscli
4. install terraform
5. install act for locally GitHub Actions
   eg.
   act -W .github/workflows/ci.yml -j test
   act -W .github/workflows/ci.yml -j lint
   act -W .github/workflows/ci.yml -j security \
    --eventpath ./local-event.json \
    -s GITHUB_TOKEN=ghp_yourgithubaccesstokenhere \
    -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest \
    --no-skip-checkout

