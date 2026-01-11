#!/bin/bash

# Setup script for Kubernetes cluster on VirtualBox
# This script automates the initial setup process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Kubernetes Cluster Setup on VirtualBox${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command_exists virtualbox; then
    echo -e "${RED}✗ VirtualBox is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ VirtualBox is installed${NC}"

if ! command_exists vagrant; then
    echo -e "${RED}✗ Vagrant is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Vagrant is installed${NC}"

if ! command_exists terraform; then
    echo -e "${RED}✗ Terraform is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Terraform is installed${NC}"

if ! command_exists ansible; then
    echo -e "${RED}✗ Ansible is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Ansible is installed${NC}"

# Check SSH key
if [ ! -f ~/.ssh/id_rsa ]; then
    echo -e "${YELLOW}SSH key not found. Generating...${NC}"
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    echo -e "${GREEN}✓ SSH key generated${NC}"
else
    echo -e "${GREEN}✓ SSH key exists${NC}"
fi

echo ""

# Setup Terraform
echo -e "${YELLOW}Setting up Terraform configuration...${NC}"
cd terraform

if [ ! -f terraform.tfvars ]; then
    cp terraform.tfvars.example terraform.tfvars
    echo -e "${GREEN}✓ Created terraform.tfvars from example${NC}"
    echo -e "${YELLOW}! Please review and edit terraform/terraform.tfvars before proceeding${NC}"
    read -p "Press Enter to continue after editing terraform.tfvars..."
fi

# Initialize Terraform
echo -e "${YELLOW}Initializing Terraform...${NC}"
terraform init

echo ""
read -p "Do you want to provision VMs now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Provisioning VMs with Terraform...${NC}"
    terraform apply -auto-approve
    echo -e "${GREEN}✓ VMs provisioned successfully${NC}"
else
    echo -e "${YELLOW}Skipping VM provisioning. Run 'cd terraform && terraform apply' manually.${NC}"
    exit 0
fi

cd ..

# Setup Ansible
echo ""
echo -e "${YELLOW}Setting up Ansible...${NC}"
cd ansible

# Install Ansible collections
echo -e "${YELLOW}Installing Ansible collections...${NC}"
ansible-galaxy collection install -r requirements.yml

echo ""
echo -e "${YELLOW}Waiting 30 seconds for VMs to be fully ready...${NC}"
sleep 30

# Test connectivity
echo -e "${YELLOW}Testing SSH connectivity to nodes...${NC}"
if ansible all -i inventory/hosts.ini -m ping; then
    echo -e "${GREEN}✓ All nodes are reachable${NC}"
else
    echo -e "${RED}✗ Some nodes are not reachable. Please check your VMs.${NC}"
    exit 1
fi

echo ""
read -p "Do you want to deploy Kubernetes now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deploying Kubernetes cluster...${NC}"
    ansible-playbook -i inventory/hosts.ini playbooks/site.yml
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Kubernetes cluster deployed successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${YELLOW}To access your cluster:${NC}"
    echo -e "  export KUBECONFIG=~/.kube/k8s-cluster-config"
    echo -e "  kubectl get nodes"
    echo ""
else
    echo -e "${YELLOW}Skipping Kubernetes deployment.${NC}"
    echo -e "${YELLOW}Run 'cd ansible && ansible-playbook -i inventory/hosts.ini playbooks/site.yml' manually.${NC}"
fi

cd ..

echo ""
echo -e "${GREEN}Setup complete!${NC}"
