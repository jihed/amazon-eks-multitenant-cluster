# EKS Tenant Manager: Multi-Tenant Kubernetes Management with KCL and ArgoCD

A GitOps-based solution for managing multiple tenants on Amazon EKS using KCL (v0.11.1) and ArgoCD. This project automates tenant provisioning, access control, and application deployment while ensuring proper isolation and security.

## Architecture Overview

```mermaid
graph TD
    subgraph "GitOps Flow"
        GIT[Git Repository] --> |1. Push Config| AS[ArgoCD ApplicationSet]
        AS --> |2. Process| KCL[KCL Plugin v0.11.1]
        KCL --> |3. Generate| K8S[Kubernetes Resources]
    end

    subgraph "Generated Resources"
        K8S --> NS[Namespaces]
        K8S --> RQ[Resource Quotas]
        K8S --> NP[Network Policies]
        K8S --> RBAC[RBAC/IAM]
        K8S --> ARGOP[ArgoCD Project]
        K8S --> APPS[ApplicationSets]
    end

    subgraph "Access Control"
        IAM[AWS IAM] --> |Authenticate| RBAC
        RBAC --> |Authorize| NS
    end
```

## Project Structure
```
.
├── base/                  # Core KCL configurations
│   ├── schema.k          # Resource schemas
│   ├── config.k          # Configuration loader
│   ├── common.k          # Common utilities
│   └── argo_schema.k     # ArgoCD schemas
├── resources/            # Resource generators
│   ├── namespace.k       # Namespace configuration
│   ├── quota.k          # Resource quotas
│   ├── limits.k         # Limit ranges
│   ├── network.k        # Network policies
│   ├── rbac.k           # RBAC rules
│   ├── applicationset.k  # ArgoCD ApplicationSets
│   └── argocd_project.k # ArgoCD Projects
├── bootstrap/           # Setup configurations
│   ├── kcl-plugin-config.yaml    # KCL plugin configuration
│   └── repo-server-patch.yaml    # ArgoCD repo server patch
└── tenants/             # Tenant configurations
    └── team-a/
        └── input.yaml   # Tenant definition
```

## Installation Steps

### 1. Install KCL Plugin for ArgoCD

```yaml
# bootstrap/kcl-plugin-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kcl-plugin
  namespace: argocd
data:
  plugin.yaml: |
    apiVersion: argoproj.io/v1alpha1
    kind: ConfigManagementPlugin
    metadata:
      name: kcl
    spec:
      version: v1.0
      generate:
        command: ["sh", "-c"]
        args: ["kcl run -o yaml -D TENANT_FILE=$ARGOCD_APP_SOURCE_PATH/input.yaml"]
```

```bash
kubectl apply -f bootstrap/kcl-plugin-config.yaml
```

### 2. Patch ArgoCD Repo Server

```yaml
# bootstrap/repo-server-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: argocd-repo-server
  namespace: argocd
spec:
  template:
    spec:
      initContainers:
        - name: kcl-install
          image: alpine:3.15
          command: [sh, -c]
          args:
            - |
              wget -O /tmp/kcl.tar.gz https://github.com/kcl-lang/kcl/releases/download/v0.11.1/kclvm-v0.11.1-linux-amd64.tar.gz &&
              tar -xf /tmp/kcl.tar.gz -C /tmp &&
              mv /tmp/kclvm-v0.11.1-linux-amd64/bin/kcl /custom-tools/ &&
              chmod +x /custom-tools/kcl
          volumeMounts:
            - mountPath: /custom-tools
              name: custom-tools
      containers:
        - name: argocd-repo-server
          volumeMounts:
            - mountPath: /usr/local/bin/kcl
              name: custom-tools
              subPath: kcl
            - mountPath: /home/argocd/cmp-server/config/plugin.yaml
              name: kcl-plugin
              subPath: plugin.yaml
      volumes:
        - name: custom-tools
          emptyDir: {}
        - name: kcl-plugin
          configMap:
            name: kcl-plugin
```

Apply the patch:
```bash
kubectl patch deployment argocd-repo-server \
  --namespace argocd \
  --patch-file bootstrap/repo-server-patch.yaml
```

## Tenant Configuration

### Example Configuration
```yaml
# tenants/team-a/input.yaml
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
      branch: main
      targetNamespace: apps
accessControl:
  groups:
    - name: apps-admin
      type: admin
      namespacePattern: "apps"
      iamRoles:
        - roleArn: "arn:aws:iam::123456789012:role/team-a-admin"
          username: "admin-user"
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

## Resource Generation Flow

```mermaid
sequenceDiagram
    participant Git as Git Repository
    participant ArgoCD as ArgoCD
    participant KCL as KCL Plugin
    participant K8S as Kubernetes

    Git->>ArgoCD: 1. Push tenant config
    ArgoCD->>KCL: 2. Process with KCL v0.11.1
    KCL->>KCL: 3. Generate resources
    Note over KCL: - Namespaces<br>- Resource Quotas<br>- Network Policies<br>- RBAC Rules<br>- ArgoCD Project<br>- ApplicationSets
    KCL->>ArgoCD: 4. Return K8s manifests
    ArgoCD->>K8S: 5. Apply resources
```

## Application Deployment Flow

```mermaid
graph TD
    subgraph "Configuration Processing"
        YAML[input.yaml] --> KCL[KCL v0.11.1]
        KCL --> ARGOP[ArgoCD Project]
        KCL --> AS[ApplicationSet]
    end

    subgraph "Application Deployment"
        AS --> APP[ArgoCD Application]
        APP --> NS[Namespace]
        GIT[Git Repository] --> APP
    end

    subgraph "Resource Controls"
        NS --> RQ[Resource Quota]
        NS --> NP[Network Policy]
        NS --> LR[Limit Range]
    end
```

## Features

- ✅ KCL v0.11.1 compatibility
- ✅ Automated tenant provisioning
- ✅ Resource quota management
- ✅ Network isolation
- ✅ IAM integration
- ✅ GitOps workflow
- ✅ Multi-environment support

## Prerequisites

- Amazon EKS cluster
- ArgoCD installed
- KCL version 0.11.1
- kubectl configured
- Git repository access

## Troubleshooting

### Common Issues

1. **KCL Plugin Issues**
```bash
# Verify KCL version
kubectl exec -it \
  $(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-repo-server -o name) \
  -n argocd \
  -- kcl --version

# Expected output: v0.11.1
```

2. **Resource Generation Issues**
```bash
# Test KCL configuration locally
kcl run -D TENANT_FILE=tenants/team-a/input.yaml

# Check ArgoCD logs
kubectl logs -n argocd \
  -l app.kubernetes.io/name=argocd-repo-server
```

3. **Application Sync Issues**
```bash
# Check Application status
argocd app list

# Check Application sync
argocd app sync <app-name>
```

## Contributing

Contributions are welcome! Please ensure you're using KCL v0.11.1 for compatibility.

## License

This project is licensed under the MIT License - see the LICENSE file for details.