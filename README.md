# Amazon EKS Multi-Tenant Cluster Manager: Secure and Efficient Kubernetes Resource Isolation

This project provides a configuration-driven approach to managing multi-tenant environments in Amazon Elastic Kubernetes Service (EKS) clusters. It enables organizations to efficiently isolate and manage resources between different teams or environments while enforcing resource quotas and network policies.

The solution implements a robust tenant management system that allows administrators to define granular resource constraints, network policies, and tenant-specific labels. Through YAML-based configuration, it supports multiple tenants with different resource requirements and security policies, making it ideal for organizations that need to maintain strict isolation between different teams or environments while maximizing cluster resource utilization.

## Repository Structure
```
amazon-eks-multitenant-cluster/
├── kcl.yaml              # KCL CLI configuration for manifest generation
└── tenant-config.yaml    # Tenant definitions with resource quotas and network policies
```

## Usage Instructions
### Prerequisites
- Amazon EKS cluster
- kubectl CLI tool installed and configured
- KCL CLI tool installed
- Cluster admin access
- ArgoCD installed on the cluster

### Installation
1. Clone the repository:
```bash
git clone <repository-url>
cd amazon-eks-multitenant-cluster
```

2. Configure ArgoCD to track this repository:
```bash
argocd app create multitenant-manager \
  --repo <repository-url> \
  --path . \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace argocd \
  --sync-policy automated
```

### Quick Start
1. Define your tenants in `tenant-config.yaml`:
```yaml
tenants:
  - name: tenant1
    labels:
      team: alpha
      environment: dev
    resourceQuota:
      cpu: "4"
      memory: "8Gi"
      pods: "10"
    networkPolicy:
      enabled: true
      allowedNamespaces:
        - kube-system
        - monitoring
```

2. Commit and push your changes:
```bash
git add tenant-config.yaml
git commit -m "Add new tenant configuration"
git push origin main
```

ArgoCD will automatically detect the changes, process the configuration using the KCL plugin, and apply the updated manifests to your cluster.

### GitOps Workflow
This repository implements a GitOps approach using ArgoCD:
1. Configuration changes are made through git commits
2. ArgoCD monitors the repository for changes
3. When changes are detected, ArgoCD uses the KCL plugin to process the configuration
4. Generated manifests are automatically applied to the cluster
5. ArgoCD ensures the cluster state matches the repository state

### More Detailed Examples
#### Creating a Production Tenant
```yaml
tenants:
  - name: tenant2
    labels:
      team: beta
      environment: prod
    resourceQuota:
      cpu: "8"
      memory: "16Gi"
      pods: "20"
    networkPolicy:
      enabled: true
      allowedNamespaces:
        - kube-system
```

### Troubleshooting
#### Resource Quota Issues
- Problem: Pods failing to schedule due to resource quota limits
- Diagnosis:
```bash
kubectl describe resourcequota -n <tenant-namespace>
kubectl get pods -n <tenant-namespace>
```
- Solution: Adjust resource quotas in tenant-config.yaml or optimize workload resource requests

#### Network Policy Issues
- Problem: Inter-namespace communication blocked
- Diagnosis:
```bash
kubectl describe networkpolicy -n <tenant-namespace>
```
- Solution: Verify allowedNamespaces configuration in tenant-config.yaml

## Data Flow
The multi-tenant configuration process uses GitOps principles to manage cluster state:

```ascii
[Git Repository] --> [ArgoCD] --> [KCL Processing] --> [Kubernetes Manifests] --> [EKS Cluster]
       |                              |                          |                      |
       |                              |                          |                      |
       v                              v                          v                      v
Tenant Definitions     Configuration Detection    Resource Quotas, Network     Applied Resources
                                                      Policies
```

Component interactions:
1. Changes are committed to the Git repository
2. ArgoCD detects configuration changes
3. KCL plugin processes the tenant configuration
4. ArgoCD applies generated manifests to the cluster
5. EKS enforces resource quotas and network policies
6. Tenant workloads are isolated based on defined policies
7. Network policies control inter-namespace communication
8. Resource quotas prevent resource overutilization

## Infrastructure

![Infrastructure diagram](./docs/infra.svg)
### Namespaces
- One namespace per tenant with defined labels

### Resource Quotas
- CPU limits: 4-8 cores per tenant
- Memory limits: 8-16Gi per tenant
- Pod limits: 10-20 pods per tenant

### Network Policies
- Enabled per tenant
- Controlled access from system namespaces
- Isolated tenant workloads

## Deployment
### Prerequisites
- EKS cluster with network policy support enabled
- Cluster admin permissions
- ArgoCD installed and configured
- KCL plugin configured in ArgoCD

### Deployment Steps
1. Configure ArgoCD to monitor this repository
2. Add or modify tenant specifications in tenant-config.yaml
3. Commit and push changes to the repository
4. ArgoCD automatically syncs and applies changes
5. Verify tenant isolation and resource quotas

### Monitoring
- Monitor resource utilization per tenant
- Track network policy effectiveness
- Review quota compliance
- Monitor ArgoCD sync status and events