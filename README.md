# Multi-Tenant Kubernetes Cluster Management with Argo CD and KCL

This project provides an automated multi-tenant management system for Kubernetes clusters using Argo CD and KCL (Kube Conformity Language). It enables organizations to efficiently manage multiple tenant workloads with strict isolation, resource quotas, and fine-grained access controls in a GitOps-driven workflow.

The system implements a hierarchical tenant management structure where each tenant gets dedicated namespaces with predefined resource limits and access controls. It leverages Argo CD's ApplicationSet feature to automatically deploy and manage tenant configurations, while using KCL as a powerful abstraction layer for generating Kubernetes manifests. The solution supports multiple teams with different access levels, resource quotas, and automated application deployments, making it ideal for organizations requiring strong multi-tenancy capabilities in their Kubernetes environments.

## Repository Structure
```
.
├── bootstrap/
│   └── kcl-argocd-plugin.yaml     # Argo CD plugin configuration for KCL manifest generation
├── clusters/
│   └── production/                 # Production environment configurations
│       ├── applicationset.yaml     # Defines automatic tenant application deployment rules
│       ├── project.yaml           # Argo CD project configuration for production tenants
│       └── tenants/
│           └── config/            # Tenant-specific configurations
│               ├── team-a/        # Team A tenant configuration
│               │   └── input.yaml # Team A specific settings and applications
│               └── team-b/        # Team B tenant configuration
│                   └── input.yaml # Team B specific settings and applications
```

## Usage Instructions

### Prerequisites

- Kubernetes cluster with Argo CD installed
- KCL CLI tool installed
- Access to AWS IAM (for role-based access control)
- Git repository access

### Installation

1. Clone the repository:
```bash
git clone https://github.com/jihed/amazon-eks-multitenant-cluster.git
cd amazon-eks-multitenant-cluster
```

2. Install the KCL plugin for Argo CD:
```bash
kubectl apply -f bootstrap/kcl-argocd-plugin.yaml
```

3. Create the Argo CD project:
```bash
kubectl apply -f clusters/production/project.yaml
```

4. Deploy the ApplicationSet:
```bash
kubectl apply -f clusters/production/applicationset.yaml
```

### Quick Start

1. Create a new tenant configuration:
```yaml
# clusters/production/tenants/config/new-team/input.yaml
name: new-team
env: prod
namespaces:
  - apps
  - tools
accessControl:
  groups:
    - name: apps-admin
      type: admin
      namespacePattern: "apps"
      iamRoles:
        - roleArn: "arn:aws:iam::123456789012:role/new-team-admin"
          username: "admin-user"
```

2. Commit and push the configuration to trigger automatic deployment.

### More Detailed Examples

#### Configuring Resource Quotas
```yaml
resourceQuota:
  cpu: "4"
  memory: "8Gi"
  pods: "20"
limitRange:
  default:
    cpu: "500m"
    memory: "512Mi"
  defaultRequest:
    cpu: "100m"
    memory: "128Mi"
  max:
    cpu: "2"
    memory: "2Gi"
```

#### Setting Up Application Deployments
```yaml
applications:
  - name: frontend
    gitRepo:
      url: https://github.com/team-a/frontend
      path: k8s/overlays/prod
      branch: main
      targetNamespace: apps
```

### Troubleshooting

#### Common Issues

1. ApplicationSet not creating applications
- Check Argo CD logs:
```bash
kubectl logs -n argocd deployment/argocd-application-controller
```
- Verify Git repository access
- Ensure correct file paths in ApplicationSet configuration

2. KCL Plugin Issues
- Verify plugin installation:
```bash
kubectl get configmap -n argocd kcl-plugin-config
```
- Check plugin logs:
```bash
kubectl logs -n argocd deployment/argocd-repo-server
```

## Data Flow

The system transforms tenant configurations into Kubernetes resources through a GitOps-driven pipeline using Argo CD and KCL.

```ascii
Git Repo                    Argo CD                     Kubernetes
[Tenant Config] --> [ApplicationSet + KCL Plugin] --> [Namespace/RBAC/Quotas]
     ^                         |                            |
     |                        v                            v
[Git Push] <---- [Status Update] <---- [Resource Status/Events]
```

Component Interactions:
1. ApplicationSet monitors the Git repository for tenant configurations
2. When changes are detected, ApplicationSet creates/updates Argo CD Applications
3. KCL plugin processes tenant configurations and generates Kubernetes manifests
4. Argo CD applies the generated manifests to the cluster
5. Kubernetes creates/updates namespaces, RBAC, and resource quotas
6. Status and events flow back to Argo CD for monitoring
7. Argo CD maintains desired state and performs automatic healing

## Infrastructure

![Infrastructure diagram](./docs/infra.svg)

### Argo CD Resources
- **ConfigMap**: `kcl-plugin-config` in `argocd` namespace for KCL plugin configuration
- **ApplicationSet**: `prod-tenant-namespaces` in `argocd` namespace for tenant management
- **AppProject**: `tenants-prod` in `argocd` namespace for production tenant isolation

### Kubernetes Resources
- **Namespaces**: Created per tenant (`apps`, `tools`)
- **ResourceQuotas**: CPU, memory, and pod limits per tenant
- **LimitRanges**: Default and maximum resource constraints
- **RBAC**: Role-based access control tied to AWS IAM roles