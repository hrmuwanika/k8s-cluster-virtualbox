# Kubernetes Cluster on VirtualBox with Terraform and Ansible

This repository provides Infrastructure as Code (IaC) to automatically provision virtual machines on VirtualBox using Terraform, and then deploy a production-ready Kubernetes cluster using Ansible.

## 📋 Table of Contents

- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Usage](#usage)
- [Cluster Details](#cluster-details)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🏗️ Architecture

This setup creates:
- **1 Master Node** (Control Plane) - 2 vCPUs, 2GB RAM
- **2 Worker Nodes** - 2 vCPUs, 2GB RAM each
- **Private Network** between nodes
- **Kubernetes v1.28+** with Containerd runtime
- **Calico CNI** for networking

## 📦 Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

1. **VirtualBox** (>= 7.0)
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install virtualbox

   # macOS
   brew install --cask virtualbox
   ```

2. **Vagrant** (>= 2.3) - Required by Terraform VirtualBox provider
   ```bash
   # Ubuntu/Debian
   sudo apt install vagrant

   # macOS
   brew install vagrant
   ```

3. **Terraform** (>= 1.5)
   ```bash
   # Ubuntu/Debian
   wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
   sudo apt update && sudo apt install terraform

   # macOS
   brew tap hashicorp/tap
   brew install hashicorp/tap/terraform
   ```

4. **Ansible** (>= 2.14)
   ```bash
   # Ubuntu/Debian
   sudo apt install ansible

   # macOS
   brew install ansible

   # Using pip (all platforms)
   pip3 install ansible
   ```

5. **SSH Keys**
   ```bash
   # Generate if you don't have one
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
   ```

### System Requirements

- **Minimum**: 8GB RAM, 4 CPU cores, 50GB free disk space
- **Recommended**: 16GB RAM, 6+ CPU cores, 100GB free disk space

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd k8s-cluster-virtualbox
```

### 2. Configure Variables

Copy and edit the example configuration:

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edit `terraform/terraform.tfvars` to customize your setup:

```hcl
vm_count_master = 1
vm_count_worker = 2
master_memory = 2048
master_cpus = 2
worker_memory = 2048
worker_cpus = 2
```

### 3. Provision VMs with Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

This will create 3 VMs (1 master, 2 workers) on VirtualBox.

### 4. Deploy Kubernetes with Ansible

```bash
cd ../ansible

# Install required Ansible collections
ansible-galaxy collection install -r requirements.yml

# Ping all nodes to verify connectivity
ansible all -i inventory/hosts.ini -m ping

# Deploy Kubernetes cluster
ansible-playbook -i inventory/hosts.ini playbooks/site.yml
```

### 5. Access Your Cluster

After successful deployment, the kubeconfig will be copied to your local machine:

```bash
export KUBECONFIG=~/.kube/k8s-cluster-config
kubectl get nodes
kubectl get pods --all-namespaces
```

## ⚙️ Configuration

### Terraform Variables

Edit `terraform/terraform.tfvars`:

| Variable | Description | Default |
|----------|-------------|---------|
| `vm_count_master` | Number of master nodes | `1` |
| `vm_count_worker` | Number of worker nodes | `2` |
| `master_memory` | Master node RAM (MB) | `2048` |
| `master_cpus` | Master node CPUs | `2` |
| `worker_memory` | Worker node RAM (MB) | `2048` |
| `worker_cpus` | Worker node CPUs | `2` |
| `network_prefix` | Network prefix | `192.168.56` |
| `base_image` | Base box image | `ubuntu/jammy64` |

### Ansible Variables

Edit `ansible/group_vars/all.yml`:

| Variable | Description | Default |
|----------|-------------|---------|
| `kubernetes_version` | Kubernetes version | `1.28.*` |
| `pod_network_cidr` | Pod network CIDR | `10.244.0.0/16` |
| `service_cidr` | Service CIDR | `10.96.0.0/12` |
| `cni_plugin` | CNI plugin (calico/flannel) | `calico` |

## 📘 Usage

### Common Commands

```bash
# Check cluster status
kubectl get nodes -o wide
kubectl cluster-info

# Deploy a test application
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort

# Scale workers
cd terraform
terraform apply -var="vm_count_worker=3"

# Destroy cluster
terraform destroy -auto-approve
```

### Managing the Cluster

```bash
# Re-run specific Ansible roles
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --tags="kubernetes"

# Update Kubernetes
ansible-playbook -i inventory/hosts.ini playbooks/upgrade.yml

# Add new worker node
# 1. Increase worker count in terraform.tfvars
# 2. Run: terraform apply
# 3. Run: ansible-playbook -i inventory/hosts.ini playbooks/add-worker.yml
```

## 🔍 Cluster Details

### Network Configuration

- **Host-Only Network**: `192.168.56.0/24`
- **Master Node**: `192.168.56.10`
- **Worker Nodes**: `192.168.56.11`, `192.168.56.12`
- **Pod Network**: `10.244.0.0/16`
- **Service Network**: `10.96.0.0/12`

### Installed Components

- **Container Runtime**: containerd
- **CNI Plugin**: Calico
- **Kubernetes Components**: kubelet, kubeadm, kubectl
- **Additional Tools**: helm, crictl, etcdctl

### Default Credentials

- **SSH User**: `vagrant`
- **SSH Key**: Auto-generated during provisioning
- **Kubeconfig**: `~/.kube/k8s-cluster-config`

## 🐛 Troubleshooting

### VMs not starting

```bash
# Check VirtualBox VMs
vboxmanage list vms
vboxmanage list runningvms

# Check Terraform state
cd terraform
terraform state list
```

### Ansible connection issues

```bash
# Test SSH connectivity
ansible all -i inventory/hosts.ini -m ping -vvv

# Verify SSH keys
ssh -i ~/.ssh/id_rsa vagrant@192.168.56.10
```

### Kubernetes pods not running

```bash
# SSH into master node
ssh vagrant@192.168.56.10

# Check kubelet status
sudo systemctl status kubelet

# Check pod logs
kubectl logs -n kube-system <pod-name>

# Check cluster info
kubectl get nodes
kubectl get pods --all-namespaces
```

### Resource constraints

If VMs fail to start due to resource constraints:

1. Reduce VM count or resources in `terraform.tfvars`
2. Close other applications to free up memory
3. Adjust VirtualBox settings for better performance

### Clean up and restart

```bash
# Destroy everything
cd terraform
terraform destroy -auto-approve

# Clean local state
rm -rf .terraform terraform.tfstate*

# Start fresh
terraform init
terraform apply -auto-approve
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform VirtualBox Provider](https://github.com/terra-farm/terraform-provider-virtualbox)
- [Ansible Documentation](https://docs.ansible.com/)

---

**Note**: This is a development/learning environment. For production use, consider managed Kubernetes services or more robust infrastructure solutions.
