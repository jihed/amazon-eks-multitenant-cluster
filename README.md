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

### Installation
1. Clone the repository:
```bash
git clone <repository-url>
cd amazon-eks-multitenant-cluster
```

2. Apply the tenant configuration:
```bash
kubectl apply -f manifest.yaml
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

2. Generate the Kubernetes manifests:
```bash
kcl manifest.yaml
```

3. Apply the configuration:
```bash
kubectl apply -f manifest.yaml
```

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
The multi-tenant configuration process transforms tenant definitions into Kubernetes resources through KCL processing and kubectl application.

```ascii
[tenant-config.yaml] --> [KCL Processing] --> [Kubernetes Manifests] --> [EKS Cluster]
     |                                              |                         |
     |                                              |                         |
     v                                              v                         v
Tenant Definitions               Resource Quotas, Network Policies     Applied Resources
```

Component interactions:
1. KCL processes the tenant configuration file to generate Kubernetes manifests
2. Manifests define namespace, resource quotas, and network policies per tenant
3. kubectl applies the manifests to the EKS cluster
4. EKS enforces resource quotas and network policies
5. Tenant workloads are isolated based on defined policies
6. Network policies control inter-namespace communication
7. Resource quotas prevent resource overutilization

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

### Deployment Steps
1. Configure tenant specifications in tenant-config.yaml
2. Generate manifests using KCL
3. Apply manifests to the cluster
4. Verify tenant isolation and resource quotas

### Monitoring
- Monitor resource utilization per tenant
- Track network policy effectiveness
- Review quota compliance