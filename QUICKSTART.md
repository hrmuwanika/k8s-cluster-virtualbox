# Quick Reference Guide

## Quick Start Commands

```bash
# 1. Clone and setup
git clone <your-repo-url>
cd k8s-cluster-virtualbox
./setup.sh

# 2. Or manual setup
cd terraform
terraform init
terraform apply -auto-approve

cd ../ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook -i inventory/hosts.ini playbooks/site.yml

# 3. Access cluster
export KUBECONFIG=~/.kube/k8s-cluster-config
kubectl get nodes
```

## Common Tasks

### Scale Worker Nodes

```bash
# Edit terraform.tfvars
vm_count_worker = 3

# Apply changes
cd terraform
terraform apply -auto-approve

# Join new worker
cd ../ansible
ansible-playbook -i inventory/hosts.ini playbooks/add-worker.yml
```

### Deploy Test Application

```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get svc nginx
```

### Access Node via SSH

```bash
# Using inventory hostname
ssh -F terraform/ssh_config k8s-master-1
ssh -F terraform/ssh_config k8s-worker-1

# Using IP directly
ssh vagrant@192.168.56.10  # master
ssh vagrant@192.168.56.11  # worker-1
```

### Troubleshooting

```bash
# Check VM status
vboxmanage list runningvms

# Test Ansible connectivity
cd ansible
ansible all -i inventory/hosts.ini -m ping

# Check cluster status
kubectl get nodes -o wide
kubectl get pods --all-namespaces

# View logs on master
ssh vagrant@192.168.56.10
sudo journalctl -u kubelet -f
```

### Upgrade Kubernetes

```bash
# Edit group_vars/all.yml
kubernetes_version: "1.29.*"

# Run upgrade playbook
cd ansible
ansible-playbook -i inventory/hosts.ini playbooks/upgrade.yml
```

### Reset/Cleanup

```bash
# Full cleanup
./cleanup.sh

# Or manual cleanup
cd ansible
ansible-playbook -i inventory/hosts.ini playbooks/reset-cluster.yml

cd ../terraform
terraform destroy -auto-approve
```

## Useful kubectl Commands

```bash
# Cluster info
kubectl cluster-info
kubectl get nodes -o wide
kubectl top nodes  # Requires metrics-server

# Deployments
kubectl get deployments --all-namespaces
kubectl get pods --all-namespaces -o wide
kubectl get services --all-namespaces

# Logs
kubectl logs -n kube-system -l component=kube-apiserver
kubectl logs -n kube-system -l k8s-app=calico-node

# Describe resources
kubectl describe node k8s-worker-1
kubectl describe pod <pod-name> -n <namespace>
```

## Network Information

| Component | IP/CIDR |
|-----------|---------|
| Master Node | 192.168.56.10 |
| Worker Node 1 | 192.168.56.11 |
| Worker Node 2 | 192.168.56.12 |
| Pod Network | 10.244.0.0/16 |
| Service Network | 10.96.0.0/12 |
| API Server | 192.168.56.10:6443 |

## File Locations

| Description | Location |
|-------------|----------|
| Terraform Config | `terraform/*.tf` |
| Terraform Variables | `terraform/terraform.tfvars` |
| Ansible Config | `ansible/ansible.cfg` |
| Inventory | `ansible/inventory/hosts.ini` |
| Playbooks | `ansible/playbooks/*.yml` |
| Group Variables | `ansible/group_vars/*.yml` |
| Local Kubeconfig | `~/.kube/k8s-cluster-config` |

## Resource Requirements

### Minimum
- 8GB RAM
- 4 CPU cores
- 50GB disk space

### Recommended
- 16GB RAM
- 6+ CPU cores
- 100GB disk space

## Default Configuration

- **Kubernetes Version**: 1.28.x
- **Container Runtime**: containerd
- **CNI Plugin**: Calico
- **Master Nodes**: 1 (2 vCPU, 2GB RAM)
- **Worker Nodes**: 2 (2 vCPU, 2GB RAM each)
