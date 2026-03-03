# moonpay

## Overview

This project provides a comprehensive setup for deploying a Kubernetes-based environment on your local machine. It leverages tools like Helm for kubernetes resource management and ArgoCD for continuous delivery.

## Prerequisites

Before you start, ensure you have the following installed on your local computer:

Kind for running a local Kubernetes cluster.
kubectl – Kubernetes command-line tool.
Helm – Kubernetes package manager.
Git – Version control system.
Flux - Gitops 
Setup Instructions

Deploy Kubernetes Cluster Locally

```bash
# This install kind, kubectl, helm and create a kind cluster

./deploy.sh
#Check access to the cluster
kubectl cluster-info

Kubernetes control plane is running at https://127.0.0.1:35841
CoreDNS is running at https://127.0.0.1:35841/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

## Kubernetes Deployment

### Prerequisites

- A running Kubernetes cluster
- Helm 3+
- `kubectl` configured

### Create the PostgreSQL secret

```bash
kubectl create secret generic postgres-postgres \
  --from-literal=POSTGRES_USER="postgres" \
  --from-literal=POSTGRES_PASSWORD="postgres" \
  --from-literal=POSTGRES_DB="currencies"
```

### Create the application secret

```bash
kubectl create secret generic moonpay-app \
  --from-literal=POSTGRES_PRISMA_URL="postgresql://postgres:postgres@prod-postgres-postgres:5432/currencies"
```

### Bootstrap flux

Set GITHUB_TOKEN env var , check https://fluxcd.io/flux/installation/bootstrap/github/#github-pat

```bash
flux bootstrap github \            
  --token-auth \   
  --components-extra=image-reflector-controller,image-automation-controller \
  --owner=javiee \
  --repository=moonpay \
  --branch=main \
  --path=clusters/prod \
  --personal
```

