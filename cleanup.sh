#!/bin/bash

# Cleanup script for Kubernetes cluster on VirtualBox
# This script destroys all VMs and cleans up configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${RED}========================================${NC}"
echo -e "${RED}Kubernetes Cluster Cleanup${NC}"
echo -e "${RED}========================================${NC}"
echo ""
echo -e "${YELLOW}WARNING: This will destroy all VMs and cluster data!${NC}"
echo ""

read -p "Are you sure you want to continue? (yes/no) " -r
echo ""
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${GREEN}Cleanup cancelled.${NC}"
    exit 0
fi

# Destroy Terraform infrastructure
echo -e "${YELLOW}Destroying VMs...${NC}"
cd terraform
if [ -f terraform.tfstate ]; then
    terraform destroy -auto-approve
    echo -e "${GREEN}✓ VMs destroyed${NC}"
else
    echo -e "${YELLOW}! No Terraform state found${NC}"
fi
cd ..

# Clean up generated files
echo -e "${YELLOW}Cleaning up generated files...${NC}"

# Remove Ansible inventory
if [ -f ansible/inventory/hosts.ini ]; then
    rm ansible/inventory/hosts.ini
    echo -e "${GREEN}✓ Removed Ansible inventory${NC}"
fi

# Remove kubeconfig
if [ -f ~/.kube/k8s-cluster-config ]; then
    rm ~/.kube/k8s-cluster-config
    echo -e "${GREEN}✓ Removed kubeconfig${NC}"
fi

# Remove temporary files
if [ -f /tmp/kubeadm-join-command.sh ]; then
    rm /tmp/kubeadm-join-command.sh
fi

if [ -f /tmp/k8s-admin.conf ]; then
    rm /tmp/k8s-admin.conf
fi

# Remove SSH config
if [ -f terraform/ssh_config ]; then
    rm terraform/ssh_config
    echo -e "${GREEN}✓ Removed SSH config${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Cleanup complete!${NC}"
echo -e "${GREEN}========================================${NC}"
