# Kubernetes Deployment

This directory contains Kubernetes manifests for deploying the Gestion Produits application on a Kubernetes cluster with Longhorn for persistent storage.

## Directory Structure

- `mysql/`: Kubernetes configuration for the MySQL version
- `postgresql/`: Kubernetes configuration for the PostgreSQL version

Each directory contains the following key files:

- `namespace.yaml`: Defines the Kubernetes namespace
- `storage-class.yaml`: Defines storage classes for persistent volumes
- `pvc.yaml`: Persistent volume claim for database storage
- `uploads-pvc.yaml`: Persistent volume claim for file uploads
- `configmap.yaml`: ConfigMap with environment variables
- `configmap-sql.yaml`: ConfigMap with SQL initialization scripts
- `secrets.yaml`: Secret with database credentials
- `db-deployment.yaml`: Database deployment configuration
- `db-service.yaml`: Database service configuration
- `migration-job.yaml`: Job to initialize the database
- `web-deployment.yaml`: Web application deployment
- `web-service.yaml`: Web application service
- `ingress.yaml`: Ingress configuration (optional)
- `kustomization.yaml`: Kustomize configuration to deploy everything together

## Prerequisites

- A running Kubernetes cluster
- Longhorn installed for persistent storage
- An Ingress controller (Traefik, Nginx, etc.)
- kubectl configured to communicate with your cluster

## Deployment Instructions

### 1. Deploy Longhorn (if not already installed)

If Longhorn is not already installed on your cluster, you can install it using:

```bash
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/master/deploy/longhorn.yaml
```

Wait for Longhorn to be ready:

```bash
kubectl -n longhorn-system get pods
```

### 2. Deploy the MySQL version

Create the namespace and deploy all resources:

```bash
kubectl apply -k k8s/mysql
```

Run the migration job to initialize the database:

```bash
kubectl -n gestion-produits-mysql create job --from=cronjob/mysql-migration-job mysql-init
```

### 3. Deploy the PostgreSQL version

Create the namespace and deploy all resources:

## Utility Scripts

Several utility scripts are available to help with deployment and maintenance:

- `deploy-k8s.sh`: Main deployment script
  - Usage: `./deploy-k8s.sh [env] [db]`
  - Example: `./deploy-k8s.sh prod mysql`

- `verify-mysql-k8s.sh`: Verify MySQL configuration
- `verify-postgresql-k8s.sh`: Verify PostgreSQL configuration
- `refactor-mysql-k8s.sh`: Clean up MySQL configuration
- `refactor-postgresql-k8s.sh`: Clean up PostgreSQL configuration
- `cleanup-temps.sh`: Remove temporary files and jobs
- `teardown-k8s.sh`: Remove deployments from the cluster

## Troubleshooting

### Database Migration

If you encounter issues with the database migration job:

1. Verify that the SQL script in `configmap-sql.yaml` is valid
2. Check if the database service is running with `kubectl get pods -n gestion-produits-mysql`
3. Inspect migration job logs with `kubectl logs job/mysql-migration-job -n gestion-produits-mysql`

### Hostname Issues

If you see errors related to server hostnames:
- Ensure the SQL scripts don't contain hardcoded references to development hostnames
- The migration jobs include automatic replacement of "fourche" hostname references with the appropriate service names

```bash
kubectl apply -k k8s/postgresql
```

Run the migration job to initialize the database:

```bash
kubectl -n gestion-produits-postgresql create job --from=cronjob/postgresql-migration-job postgresql-init
```

### 4. Configure Ingress

Update the hosts in the ingress files to match your domain:

```bash
# Edit MySQL ingress
vim k8s/mysql/ingress.yaml

# Edit PostgreSQL ingress
vim k8s/postgresql/ingress.yaml
```

Apply the ingress configurations:

```bash
kubectl apply -f k8s/mysql/ingress.yaml
kubectl apply -f k8s/postgresql/ingress.yaml
```

### 5. Configure DNS

Add entries to your local hosts file or DNS server:

```
<CLUSTER_IP> www.gestion-produits.local
<CLUSTER_IP> dev.gestion-produits.local
```

## Access the Application

- MySQL version: https://www.gestion-produits.local
- PostgreSQL version: https://dev.gestion-produits.local

## Scaling

To scale the application, you can change the number of replicas for the web deployments:

```bash
kubectl -n gestion-produits-mysql scale deployment web-deployment-mysql --replicas=5
kubectl -n gestion-produits-postgresql scale deployment web-deployment-postgresql --replicas=5
```

## Monitoring

You can monitor the status of your pods using:

```bash
kubectl -n gestion-produits-mysql get pods
kubectl -n gestion-produits-postgresql get pods
```

To view logs:

```bash
kubectl -n gestion-produits-mysql logs deployment/web-deployment-mysql
kubectl -n gestion-produits-mysql logs deployment/mysql-deployment
```

## Cleanup

To remove the deployments:

```bash
kubectl delete namespace gestion-produits-mysql
kubectl delete namespace gestion-produits-postgresql
```
