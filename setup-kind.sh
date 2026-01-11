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
    
    # Check Docker
    if command -v docker &> /dev/null; then
        print_success "Docker is installed"
        if docker ps &> /dev/null; then
            print_success "Docker is running"
        else
            print_error "Docker is not running"
            all_ok=false
        fi
    else
        print_error "Docker is not installed"
        all_ok=false
    fi
    
    # Check kubectl
    if command -v kubectl &> /dev/null; then
        print_success "kubectl is installed"
    else
        print_info "kubectl not found, will install it"
    fi
    
    # Check kind
    if command -v kind &> /dev/null; then
        print_success "kind is installed"
    else
        print_info "kind not found, will install it"
    fi
    
    if [ "$all_ok" = false ]; then
        echo ""
        print_error "Please install Docker and ensure it's running"
        echo ""
        echo "Installation: https://docs.docker.com/get-docker/"
        exit 1
    fi
}

# Install kind if not present
install_kind() {
    if ! command -v kind &> /dev/null; then
        print_header "Installing kind (Kubernetes in Docker)"
        
        print_info "Downloading kind..."
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
        chmod +x ./kind
        sudo mv ./kind /usr/local/bin/kind
        
        print_success "kind installed successfully"
    fi
}

# Install kubectl if not present
install_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_header "Installing kubectl"
        
        print_info "Downloading kubectl..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/kubectl
        
        print_success "kubectl installed successfully"
    fi
}

# Create Kubernetes cluster with kind
create_cluster() {
    print_header "Creating Kubernetes Cluster with kind"
    
    # Check if cluster already exists
    if kind get clusters 2>/dev/null | grep -q "^k8s-node-api$"; then
        print_info "Cluster 'k8s-node-api' already exists, deleting it..."
        kind delete cluster --name k8s-node-api
    fi
    
    print_info "Creating multi-node cluster..."
    cat <<EOF | kind create cluster --name k8s-node-api --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 30080
    protocol: TCP
- role: worker
- role: worker
EOF
    
    print_success "Cluster created successfully"
    
    # Set kubectl context
    kubectl cluster-info --context kind-k8s-node-api
}

# Build and load Docker image
build_and_load_image() {
    print_header "Building Application Docker Image"
    
    cd app
    
    print_info "Building Docker image..."
    docker build -t node-rest-api:latest .
    
    print_info "Loading image into kind cluster..."
    kind load docker-image node-rest-api:latest --name k8s-node-api
    
    print_success "Image loaded into cluster"
    
    cd ..
}

# Deploy application
deploy_application() {
    print_header "Deploying Node.js REST API"
    
    print_info "Applying Kubernetes manifests..."
    kubectl apply -f app/deployment.yaml
    
    print_info "Waiting for pods to be ready..."
    kubectl wait --for=condition=ready pod -l app=node-api -n node-api --timeout=120s
    
    print_success "Application deployed successfully"
}

# Display access information
show_access_info() {
    print_header "Installation Complete!"
    
    echo "Your Kubernetes cluster is ready with the Node.js REST API deployed!"
    echo ""
    echo "Cluster Information:"
    echo "-------------------"
    kubectl get nodes
    echo ""
    echo "Application Pods:"
    echo "----------------"
    kubectl get pods -n node-api -o wide
    echo ""
    echo "Services:"
    echo "---------"
    kubectl get svc -n node-api
    echo ""
    echo "Access the REST API:"
    echo "-------------------"
    echo "URL: http://localhost:30080"
    echo ""
    echo "Test commands:"
    echo "  curl http://localhost:30080"
    echo "  curl http://localhost:30080/health"
    echo "  curl http://localhost:30080/api/items"
    echo ""
    echo "Create an item:"
    echo "  curl -X POST http://localhost:30080/api/items \\"
    echo "    -H 'Content-Type: application/json' \\"
    echo "    -d '{\"name\":\"Test Item\",\"description\":\"Demo\"}'"
    echo ""
    echo "Useful commands:"
    echo "---------------"
    echo "  kubectl get all -n node-api       # View all resources"
    echo "  kubectl logs -n node-api -l app=node-api  # View logs"
    echo "  kubectl exec -it -n node-api <pod-name> -- sh  # Shell into pod"
    echo ""
    echo "Cleanup:"
    echo "--------"
    echo "  kind delete cluster --name k8s-node-api"
    echo ""
}

# Main execution
main() {
    clear
    print_header "Kubernetes Node.js REST API Cluster (kind)"
    
    check_prerequisites
    install_kind
    install_kubectl
    create_cluster
    build_and_load_image
    deploy_application
    show_access_info
    
    echo ""
    print_success "All done! Visit http://localhost:30080 to test your API!"
    echo ""
}

# Run main function
main
