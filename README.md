# Kubernetes Multi-Tenant Configuration Management System

This project provides a robust multi-tenant configuration management system for Kubernetes clusters that enables teams to define and manage their namespace resources, access controls, and resource quotas through declarative YAML configurations.

The system implements a tenant-based architecture that separates different teams' resources and permissions while enforcing consistent resource limits and security policies. It automatically generates the necessary Kubernetes resources including namespaces, resource quotas, limit ranges, network policies, and RBAC configurations based on tenant-specific input files. This approach ensures proper resource isolation, secure access controls, and efficient resource utilization across all tenant workloads.

## Data Flow
The system processes tenant configurations to generate Kubernetes resources through a structured pipeline that enforces security and resource constraints.

```ascii
Input YAML                 KCL Processing              Output Resources
[team-x/input.yaml] --> [Resource Generation] --> [Namespaces]
                                              --> [Resource Quotas]
                                              --> [Limit Ranges]
                                              --> [Network Policies]
                                              --> [RBAC Configs]
```

Key component interactions:
1. Input YAML files define tenant configurations and requirements
2. KCL processes the input files and generates standardized Kubernetes resources
3. Network policies enforce isolation between tenant namespaces
4. RBAC configurations manage access through IAM role integration
5. Resource quotas and limit ranges ensure fair resource allocation
6. Generated resources are applied to the Kubernetes cluster
7. Tenant workloads are deployed within their designated namespaces

## Repository Structure
```
clusters/
└── production/
    ├── applicationset.yaml
    ├── config/
    │   └── kcl.mod.lock
    ├── project.yaml
    └── tenants/
        ├── team-a/
        │   └── input.yaml        # Team A's tenant configuration including apps and access controls
        └── team-b/
            └── input.yaml        # Team B's tenant configuration including access controls
```

## Configuration Details

### Tenant Input Configuration (input.yaml)
Each tenant's `input.yaml` file defines their complete configuration:

```yaml
name: team-a                # Tenant identifier
env: prod                   # Environment (e.g., prod, dev)
namespaces:                 # List of namespaces for the tenant
  - apps
  - tools
applications:              # Optional: Applications to be deployed
  - name: guestbook
    gitRepo:
      url: https://github.com/argoproj/argocd-example-apps/
      path: guestbook
      branch: HEAD
      targetNamespace: apps
accessControl:             # Access control configuration
  groups:
    - name: apps-admin
      type: admin
      namespacePattern: "apps"
      iamRoles:
        - roleArn: "arn:aws:iam::123456789012:role/team-a-admin"
          username: "admin-user"
resourceQuota:             # Tenant-wide resource limits
  cpu: "4"
  memory: "8Gi"
  pods: "20"
limitRange:               # Container-level resource constraints
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

### Argo ApplicationSet Configuration
The ApplicationSet controller automatically manages tenant applications based on the input.yaml files:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: prod-generator
  namespace: argocd
spec:
  generators:
    - git:
        repoURL: https://github.com/jihed/amazon-eks-tenant-manager.git
        revision: HEAD
        files:
        - path: "clusters/production/tenants/*/input.yaml"
  template:
    metadata:
      name: '{{path.basename}}-prod'
      labels:
        tenant: '{{path.basename}}'
        environment: production
    spec:
      project: tenants-prod
      source:
        path: 'clusters/production/config'
        plugin:
          name: kcl-v1.0
          parameters:
            - name: TENANT_FILE
              string: "../tenants/{{path.basename}}/input.yaml"
```

The ApplicationSet:
- Discovers tenant configurations using Git generator
- Creates an Argo CD application for each tenant
- Applies consistent naming and labeling
- Uses KCL plugin to process tenant configurations
- Enables automated synchronization and pruning

### Argo Project Configuration
The `project.yaml` defines the security boundaries and permissions:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: tenants-prod
  namespace: argocd
spec:
  description: "Production Tenant Manager Project"
  sourceRepos:
    - "https://github.com/jihed/amazon-eks-tenant-manager.git"
  destinations:
    - namespace: '*'
      server: https://kubernetes.default.svc
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
```

The Project configuration:
- Defines allowed source repositories
- Controls which clusters and namespaces can be targeted
- Specifies which Kubernetes resources can be managed
- Provides isolation between different tenant applications

[Rest of README remains exactly the same...]