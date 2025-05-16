#!/bin/bash

# Colors for output formatting
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print messages with timestamp
log() {
    local level=$1
    local message=$2
    local color=$3
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${color}[${timestamp}] [${level}] ${message}${NC}"
}

info() {
    log "INFO" "$1" "${BLUE}"
}

success() {
    log "SUCCESS" "$1" "${GREEN}"
}

warn() {
    log "WARNING" "$1" "${YELLOW}"
}

error() {
    log "ERROR" "$1" "${RED}"
}

# Check if kubectl is installed
check_kubectl() {
    info "Checking if kubectl is installed..."
    if ! command -v kubectl &> /dev/null; then
        error "kubectl is not installed. Please install kubectl and try again."
        exit 1
    fi
    success "kubectl is installed"
}

# Check if Kubernetes cluster is accessible
check_cluster() {
    info "Checking if Kubernetes cluster is accessible..."
    if ! kubectl cluster-info &> /dev/null; then
        error "Failed to connect to Kubernetes cluster. Please check your kubeconfig and cluster status."
        exit 1
    fi
    success "Kubernetes cluster is accessible"
}

# Delete MySQL deployment
delete_mysql() {
    info "Deleting MySQL deployment..."
    
    if kubectl -n gestion-produits-mysql delete ingress gestion-produits-mysql-ingress --ignore-not-found=true; then
        success "MySQL ingress deleted"
    else
        warn "Failed to delete MySQL ingress or it doesn't exist"
    fi
    
    if kubectl delete namespace gestion-produits-mysql --ignore-not-found=true; then
        success "MySQL namespace and all resources deleted"
    else
        error "Failed to delete MySQL namespace"
        return 1
    fi
    
    return 0
}

# Delete PostgreSQL deployment
delete_postgresql() {
    info "Deleting PostgreSQL deployment..."
    
    if kubectl -n gestion-produits-postgresql delete ingress gestion-produits-postgresql-ingress --ignore-not-found=true; then
        success "PostgreSQL ingress deleted"
    else
        warn "Failed to delete PostgreSQL ingress or it doesn't exist"
    fi
    
    if kubectl delete namespace gestion-produits-postgresql --ignore-not-found=true; then
        success "PostgreSQL namespace and all resources deleted"
    else
        error "Failed to delete PostgreSQL namespace"
        return 1
    fi
    
    return 0
}

# Main function
main() {
    echo -e "${RED}========================================"
    echo -e "Gestion Produits - Kubernetes Teardown"
    echo -e "========================================${NC}"
    echo
    
    # Check prerequisites
    check_kubectl
    check_cluster
    
    # Confirm before proceeding
    read -p "This will delete ALL resources related to Gestion Produits. Continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Operation cancelled"
        exit 0
    fi
    
    # Perform teardown
    delete_mysql
    delete_postgresql
    
    echo -e "${GREEN}Teardown completed!${NC}"
}

# Execute main function
main
