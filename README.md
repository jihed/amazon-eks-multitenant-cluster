# Amazon EKS Multi-Tenant Configuration with KCL

This project provides a KCL-based configuration for managing multi-tenant environments on Amazon EKS. It automates the creation of namespaces, resource quotas, network policies, and Argo CD configurations for each tenant.

## Architecture

```mermaid
graph TD
    subgraph "Input Configuration"
        YAML[Tenant YAML] --> KCL[KCL Processor]
    end

    subgraph "Resource Generation"
        KCL --> NS[Namespaces]
        KCL --> RQ[Resource Quotas]
        KCL --> NP[Network Policies]
        KCL --> RBAC[RBAC]
        KCL --> ARGO[Argo CD Resources]
    end

    subgraph "EKS Cluster"
        NS --> |creates| NSP[Tenant Namespaces]
        RQ --> |applies| RQP[Quota Limits]
        NP --> |enforces| NPP[Network Isolation]
        RBAC --> |manages| RBACP[Access Control]
        ARGO --> |deploys| APPS[Applications]
    end

    subgraph "Tenant Access"
        IAM[IAM Roles] --> |authenticates| RBACP
        RBACP --> |authorizes| NSP
    end

    subgraph "Application Deployment"
        GIT[Git Repositories] --> |source| APPS
        APPS --> |deploys to| NSP
    end
```

## Project Structure

```
.
├── base/
│   ├── schema.k          # Core schemas for resources
│   ├── config.k          # Configuration loader
│   ├── common.k          # Common utilities
│   └── argo_schema.k     # Argo CD specific schemas
├── resources/
│   ├── namespace.k       # Namespace resources
│   ├── quota.k          # Resource quotas
│   ├── limits.k         # Limit ranges
│   ├── network.k        # Network policies
│   ├── rbac.k           # RBAC configuration
│   ├── applicationset.k # Argo CD ApplicationSets
│   └── argocd_project.k # Argo CD Projects
└── tenants/
    └── team-a/
        └── input.yaml   # Tenant configuration
```

## Resource Overview

```mermaid
graph TD
    subgraph "Tenant Resources"
        direction LR
        NS[Namespace] --> RQ[ResourceQuota]
        NS --> LR[LimitRange]
        NS --> NP[NetworkPolicy]
        NS --> RBAC[RBAC]
    end

    subgraph "Argo CD Resources"
        direction LR
        PROJ[Project] --> AS[ApplicationSet]
        AS --> APP[Application]
    end

    subgraph "Security"
        direction LR
        IAM[IAM Role] --> RB[RoleBinding]
        RB --> ROLE[Role]
        NP --> |allows| SVC[Shared Services]
    end
```

## Generated Resources

1. **Namespace Configuration**
   - Isolated namespaces per tenant
   - Resource quotas and limits
   - Network policies
   - RBAC configuration

2. **Resource Management**
```mermaid
graph LR
    subgraph "Resource Controls"
        RQ[ResourceQuota] --> |limits| CPU[CPU: 4]
        RQ --> |limits| MEM[Memory: 8Gi]
        RQ --> |limits| PODS[Pods: 20]
        LR[LimitRange] --> |defines| DEF[Default Limits]
        LR --> |defines| REQ[Request Limits]
        LR --> |defines| MAX[Max Limits]
    end
```

3. **Network Policies**
```mermaid
graph TD
    subgraph "Network Isolation"
        NP[NetworkPolicy] --> |allows| INT[Internal Communication]
        NP --> |allows| DNS[DNS Access]
        NP --> |allows| MON[Monitoring]
        NP --> |allows| LOG[Logging]
    end
```

4. **Argo CD Integration**
```mermaid
graph LR
    subgraph "Application Deployment"
        PROJ[Project] --> |contains| AS[ApplicationSet]
        AS --> |generates| APP[Applications]
        APP --> |deploys to| NS[Namespace]
        GIT[Git Repository] --> |source| APP
    end
```

## Usage

1. Create tenant configuration:
```yaml
name: team-a
env: prod
namespaces:
  - apps
  - tools
applications:
  - name: frontend
    gitRepo:
      url: https://github.com/team-a/frontend
      path: k8s/overlays/prod
      targetNamespace: apps
```

2. Apply configuration:
```bash
kcl run -D TENANT_FILE=team-a/input.yaml | kubectl apply -f -
```

## Features

- ✅ Namespace Isolation
- ✅ Resource Quotas
- ✅ Network Policies
- ✅ RBAC Integration
- ✅ Argo CD Integration
- ✅ IAM Role Integration
- ✅ GitOps Workflow

## Requirements

- KCL version 0.11.1
- Amazon EKS cluster
- Argo CD installed
- kubectl configured

## Security Considerations

```mermaid
graph TD
    subgraph "Security Layers"
        IAM[IAM Authentication] --> RBAC[RBAC Authorization]
        RBAC --> NS[Namespace Isolation]
        NS --> NP[Network Policies]
        NP --> RQ[Resource Limits]
    end
```

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
