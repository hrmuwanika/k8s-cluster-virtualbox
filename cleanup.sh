#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

echo "==========================================="
echo "  Cleaning up Kubernetes Cluster"
echo "==========================================="
echo ""

print_info "Destroying Terraform infrastructure..."
cd terraform
terraform destroy -auto-approve
cd ..

print_success "Cleanup complete!"
echo ""
echo "All VMs and resources have been destroyed."
