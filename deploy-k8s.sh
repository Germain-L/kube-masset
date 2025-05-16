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

# Check if Longhorn is installed
check_longhorn() {
    info "Checking if Longhorn is installed..."
    if ! kubectl -n longhorn-system get deployment longhorn-driver-deployer &> /dev/null; then
        warn "Longhorn might not be installed. You might need to install it first:"
        warn "kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/master/deploy/longhorn.yaml"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        success "Longhorn appears to be installed"
    fi
}

# Create namespaces
create_namespaces() {
    info "Creating namespaces..."
    
    if ! kubectl get namespace gestion-produits-mysql &> /dev/null; then
        kubectl create namespace gestion-produits-mysql
        success "Created namespace: gestion-produits-mysql"
    else
        warn "Namespace gestion-produits-mysql already exists"
    fi
    
    if ! kubectl get namespace gestion-produits-postgresql &> /dev/null; then
        kubectl create namespace gestion-produits-postgresql
        success "Created namespace: gestion-produits-postgresql"
    else
        warn "Namespace gestion-produits-postgresql already exists"
    fi
}

# Deploy MySQL version
deploy_mysql() {
    info "Deploying MySQL version..."
    
    if kubectl apply -k k8s/mysql/; then
        success "MySQL version deployed successfully"
    else
        error "Failed to deploy MySQL version"
        return 1
    fi
    
    info "Waiting for MySQL deployment to be ready..."
    kubectl -n gestion-produits-mysql rollout status deployment/mysql-deployment --timeout=180s
    if [ $? -eq 0 ]; then
        success "MySQL deployment is ready"
    else
        warn "MySQL deployment not ready within timeout, continuing anyway"
    fi
    
    info "Waiting for MySQL web deployment to be ready..."
    kubectl -n gestion-produits-mysql rollout status deployment/web-deployment-mysql --timeout=180s
    if [ $? -eq 0 ]; then
        success "MySQL web deployment is ready"
    else
        warn "MySQL web deployment not ready within timeout, continuing anyway"
    fi
    
    return 0
}

# Deploy PostgreSQL version
deploy_postgresql() {
    info "Deploying PostgreSQL version..."
    
    if kubectl apply -k k8s/postgresql/; then
        success "PostgreSQL version deployed successfully"
    else
        error "Failed to deploy PostgreSQL version"
        return 1
    fi
    
    info "Waiting for PostgreSQL deployment to be ready..."
    kubectl -n gestion-produits-postgresql rollout status deployment/postgresql-deployment --timeout=180s
    if [ $? -eq 0 ]; then
        success "PostgreSQL deployment is ready"
    else
        warn "PostgreSQL deployment not ready within timeout, continuing anyway"
    fi
    
    info "Waiting for PostgreSQL web deployment to be ready..."
    kubectl -n gestion-produits-postgresql rollout status deployment/web-deployment-postgresql --timeout=180s
    if [ $? -eq 0 ]; then
        success "PostgreSQL web deployment is ready"
    else
        warn "PostgreSQL web deployment not ready within timeout, continuing anyway"
    fi
    
    return 0
}

# Run migration jobs
run_migrations() {
    info "Running MySQL migration job..."
    kubectl -n gestion-produits-mysql create job --from=cronjob/mysql-migration-job mysql-init-$(date +%s) 2>/dev/null || \
    kubectl -n gestion-produits-mysql create job mysql-init-$(date +%s) --image=mariadb:10.6 -- /bin/bash -c \
      "mysql -h mysql-service -u root -prootpassword < /docker-entrypoint-initdb.d/gestion_produits.sql" \
      && success "MySQL migration job created" || warn "Could not create MySQL migration job"
    
    info "Running PostgreSQL migration job..."
    kubectl -n gestion-produits-postgresql create job --from=cronjob/postgresql-migration-job postgresql-init-$(date +%s) 2>/dev/null || \
    kubectl -n gestion-produits-postgresql create job postgresql-init-$(date +%s) --image=postgres:14-alpine -- /bin/bash -c \
      "PGPASSWORD=devpassword psql -h postgresql-service -U gestionuser -d gestiondb -f /docker-entrypoint-initdb.d/init.sql" \
      && success "PostgreSQL migration job created" || warn "Could not create PostgreSQL migration job"
}

# Apply ingress configurations
apply_ingress() {
    info "Setting up ingress for MySQL version..."
    if kubectl apply -f k8s/mysql/ingress.yaml; then
        success "MySQL ingress created"
    else
        warn "Failed to create MySQL ingress"
    fi
    
    info "Setting up ingress for PostgreSQL version..."
    if kubectl apply -f k8s/postgresql/ingress.yaml; then
        success "PostgreSQL ingress created"
    else
        warn "Failed to create PostgreSQL ingress"
    fi
    
    info "Getting ingress information..."
    echo
    echo "MySQL Ingress:"
    kubectl -n gestion-produits-mysql get ingress
    echo
    echo "PostgreSQL Ingress:"
    kubectl -n gestion-produits-postgresql get ingress
    echo
}

# Display application access information
show_access_info() {
    echo
    info "========================================"
    info "Gestion Produits has been deployed!"
    info "========================================"
    echo
    echo "To access the applications, add these entries to your /etc/hosts file:"
    
    # Attempt to get IP address of ingress
    mysql_ip=$(kubectl -n gestion-produits-mysql get ingress -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    pg_ip=$(kubectl -n gestion-produits-postgresql get ingress -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    
    if [ -z "$mysql_ip" ]; then
        mysql_ip="<CLUSTER_IP>"
    fi
    
    if [ -z "$pg_ip" ]; then
        pg_ip="<CLUSTER_IP>"
    fi
    
    echo -e "${BLUE}$mysql_ip www.gestion-produits.local${NC}"
    echo -e "${BLUE}$pg_ip dev.gestion-produits.local${NC}"
    echo
    echo "Then access the applications at:"
    echo -e "${GREEN}https://www.gestion-produits.local${NC} (MySQL version)"
    echo -e "${GREEN}https://dev.gestion-produits.local${NC} (PostgreSQL version)"
    echo
}

# Main function
main() {
    echo -e "${BLUE}========================================"
    echo -e "Gestion Produits - Kubernetes Deployment"
    echo -e "========================================${NC}"
    echo
    
    # Check prerequisites
    check_kubectl
    check_cluster
    check_longhorn
    
    # Perform deployment steps
    create_namespaces
    deploy_mysql
    deploy_postgresql
    run_migrations
    apply_ingress
    show_access_info
    
    echo -e "${GREEN}Deployment script completed!${NC}"
}

# Execute main function
main
