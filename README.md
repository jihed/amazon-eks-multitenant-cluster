# Multi-Tenant Kubernetes Configuration on Amazon EKS with KCL

This repository provides KCL configurations for managing multi-tenant Kubernetes namespaces and associated resources using GitOps methodology with ArgoCD and KCL plugin.

## Architecture

The configuration generates these Kubernetes resources per tenant:
- Namespaces with labels and annotations
- ResourceQuotas for resource management
- LimitRanges for container constraints
- NetworkPolicies for namespace isolation
  - Allows intra-tenant communication
  - Allows kube-dns access
  - Blocks all other traffic

## Directory Structure

```
.
├── base/
│   ├── schema.k          # Tenant and resource schemas
│   └── config.k          # Tenant configuration loader
├── resources/
│   ├── namespace.k       # Namespace resource generation
│   ├── quota.k          # ResourceQuota generation
│   ├── limits.k         # LimitRange generation
│   └── network.k        # NetworkPolicy generation
├── tenants/             # Tenant YAML configurations
│   ├── team-a.yaml
│   └── team-b.yaml
└── main.k               # Main resource compilation
```

## Prerequisites

- KCL v0.11.1
- ArgoCD with KCL plugin
- Kubernetes cluster access

## Usage

### Tenant Configuration

Create tenant configurations in `tenants/` directory:

```yaml
# tenants/team-a.yaml
name: team-a
env: production
namespaces: 
  - team-a-ns1
  - team-a-ns2
resourceQuota:
  cpu: "4"
  memory: "8Gi"
  pods: "20"
  services: "10"
  configmaps: "20"
  secrets: "20"
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

### Local Testing

```bash
# Validate configuration
kcl run

# Apply to cluster
kcl run | kubectl apply -f -
```

### ArgoCD Integration

1. Install ArgoCD KCL plugin
2. Create ArgoCD Application:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: tenant-namespaces
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://your-git-repo
    targetRevision: HEAD
    path: .
    plugin:
      name: kcl
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Generated Resources

### Namespace
- Labels:
  - team
  - environment
  - managed-by: kcl

### ResourceQuota
Configurable limits for:
- CPU
- Memory
- Pods
- Services
- ConfigMaps
- Secrets

### LimitRange
Container constraints for:
- Default limits
- Default requests
- Maximum limits

### NetworkPolicy
- Allows communication between tenant namespaces
- Allows DNS access (UDP/TCP port 53)
- Blocks other traffic

## Best Practices

### GitOps Workflow
- Make changes through git
- Use ArgoCD for deployment
- Monitor sync status

### Tenant Management
- One YAML file per tenant
- Use meaningful namespace names
- Document resource quotas

### Version Control
- Commit all changes
- Use branch protection
- Review changes

## Troubleshooting

### ArgoCD Sync Issues
- Verify KCL plugin installation
- Check YAML syntax
- Validate resources

### Resource Conflicts
- Check namespace uniqueness
- Verify quota settings
- Review network policies

## Contributing

1. Fork repository
2. Create feature branch
3. Submit pull request

## Support

Create an issue in the repository for:
- Bug reports
- Feature requests
- Documentation improvements

Let me know if you need any clarification or have questions!