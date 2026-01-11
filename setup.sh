#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    local all_ok=true
    
    # Check VirtualBox
    if command -v VBoxManage &> /dev/null; then
        print_success "VirtualBox is installed"
    else
        print_error "VirtualBox is not installed"
        all_ok=false
    fi
    
    # Check Terraform
    if command -v terraform &> /dev/null; then
        print_success "Terraform is installed"
    else
        print_error "Terraform is not installed"
        all_ok=false
    fi
    
    # Check Ansible
    if command -v ansible &> /dev/null; then
        print_success "Ansible is installed"
    else
        print_error "Ansible is not installed"
        all_ok=false
    fi
    
    if [ "$all_ok" = false ]; then
        echo ""
        print_error "Please install missing prerequisites"
        echo ""
        echo "Installation commands:"
        echo "  VirtualBox: https://www.virtualbox.org/wiki/Downloads"
        echo "  Terraform:  https://www.terraform.io/downloads"
        echo "  Ansible:    pip install ansible"
        exit 1
    fi
}

# Provision VMs with Terraform
provision_vms() {
    print_header "Step 1: Provisioning VirtualBox VMs with Terraform"
    
    cd terraform
    
    print_info "Initializing Terraform..."
    terraform init
    
    print_info "Planning infrastructure..."
    terraform plan
    
    print_info "Applying Terraform configuration..."
    terraform apply -auto-approve
    
    print_success "VMs provisioned successfully"
    
    # Display VM information
    echo ""
    echo "VM Information:"
    terraform output
    
    cd ..
}

# Setup Kubernetes cluster with Ansible
setup_kubernetes() {
    print_header "Step 2: Setting up Kubernetes Cluster with Ansible"
    
    cd ansible
    
    print_info "Waiting for VMs to be ready (30 seconds)..."
    sleep 30
    
    print_info "Preparing nodes..."
    ansible-playbook playbooks/prepare-nodes.yml
    
    print_info "Initializing master node..."
    ansible-playbook playbooks/master-init.yml
    
    print_info "Joining worker nodes..."
    ansible-playbook playbooks/workers-join.yml
    
    print_success "Kubernetes cluster is ready"
    
    cd ..
}

# Deploy Node.js REST API
deploy_application() {
    print_header "Step 3: Deploying Node.js REST API"
    
    cd ansible
    
    print_info "Building and deploying application..."
    ansible-playbook playbooks/deploy-app.yml
    
    print_success "Application deployed successfully"
    
    cd ..
}

# Display access information
show_access_info() {
    print_header "Installation Complete!"
    
    echo "Your Kubernetes cluster is ready with the Node.js REST API deployed!"
    echo ""
    echo "Cluster Information:"
    echo "-------------------"
    cd terraform
    MASTER_IP=$(terraform output -raw master_ip 2>/dev/null || echo "Check terraform output")
    cd ..
    
    echo "Master Node IP: $MASTER_IP"
    echo ""
    echo "Access the Kubernetes cluster:"
    echo "------------------------------"
    echo "1. SSH to master node:"
    echo "   ssh vagrant@$MASTER_IP"
    echo ""
    echo "2. Check cluster status:"
    echo "   ssh vagrant@$MASTER_IP 'kubectl get nodes'"
    echo "   ssh vagrant@$MASTER_IP 'kubectl get pods -n node-api'"
    echo ""
    echo "3. Access the REST API:"
    echo "   http://$MASTER_IP:30080"
    echo ""
    echo "API Endpoints:"
    echo "--------------"
    echo "  GET  http://$MASTER_IP:30080/"
    echo "  GET  http://$MASTER_IP:30080/health"
    echo "  GET  http://$MASTER_IP:30080/api/items"
    echo "  POST http://$MASTER_IP:30080/api/items"
    echo ""
    echo "Test the API:"
    echo "-------------"
    echo "curl http://$MASTER_IP:30080"
    echo "curl -X POST http://$MASTER_IP:30080/api/items \\"
    echo "  -H 'Content-Type: application/json' \\"
    echo "  -d '{\"name\":\"Test Item\",\"description\":\"Created via API\"}'"
    echo ""
    echo "Cleanup:"
    echo "--------"
    echo "To destroy all resources: cd terraform && terraform destroy"
}

# Main execution
main() {
    clear
    print_header "Kubernetes Node.js REST API Cluster Setup"
    
    check_prerequisites
    provision_vms
    setup_kubernetes
    deploy_application
    show_access_info
    
    echo ""
    print_success "All done! Happy coding!"
    echo ""
}

# Run main function
main
