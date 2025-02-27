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
    └── tenants/
        └── config/
            ├── kcl.mod.lock          # Lock file for KCL dependencies
            ├── outputs.yaml          # Generated Kubernetes resources for all tenants
            ├── team-a/              
            │   └── input.yaml        # Team A's tenant configuration including apps and access controls
            └── team-b/
                └── input.yaml        # Team B's tenant configuration including access controls
```

## Usage Instructions
### Prerequisites
- Kubernetes cluster with RBAC enabled
- kubectl CLI tool installed and configured
- Access to AWS IAM (for IAM role integration)
- KCL toolchain installed

### Installation
1. Clone the repository:
```bash
git clone <repository-url>
cd <repository-name>
```

2. Apply the tenant configurations:
```bash
kubectl apply -f clusters/production/tenants/config/outputs.yaml
```

### Quick Start
1. Create a new tenant configuration:
```yaml
# clusters/production/tenants/config/team-new/input.yaml
name: team-new
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
        - roleArn: "arn:aws:iam::123456789012:role/team-new-admin"
          username: "admin-user"
resourceQuota:
  cpu: "4"
  memory: "8Gi"
  pods: "20"
```

2. Generate the Kubernetes resources:
```bash
kcl run clusters/production/tenants/config
```

3. Apply the generated configuration:
```bash
kubectl apply -f clusters/production/tenants/config/outputs.yaml
```

## Application Onboarding
To onboard applications using the tenant configuration system, follow these steps:

1. Create or update your team's input.yaml file with the application definitions:
```yaml
# clusters/production/tenants/config/team-a/input.yaml
applications:
  - name: frontend
    gitRepo:
      url: https://github.com/team-a/frontend
      path: k8s/overlays/prod    # Path to Kubernetes manifests
      branch: main              # Target branch for deployments
      targetNamespace: apps     # Namespace where app will be deployed
  - name: backend
    gitRepo:
      url: https://github.com/team-a/backend
      path: k8s/overlays/prod
      targetNamespace: apps
```

2. Configure application resource constraints:
```yaml
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

3. Set up access controls for application management:
```yaml
accessControl:
  groups:
    - name: apps-admin
      type: admin
      namespacePattern: "apps"
      iamRoles:
        - roleArn: "arn:aws:iam::123456789012:role/team-a-admin"
          username: "admin-user"
```

4. Apply the configuration:
```bash
kcl run clusters/production/tenants/config
kubectl apply -f clusters/production/tenants/config/outputs.yaml
```

5. Verify application deployment:
```bash
kubectl get applications -n <team>-prod-apps
kubectl get pods -n <team>-prod-apps
```

### More Detailed Examples
#### Configuring Applications
```yaml
applications:
  - name: frontend
    gitRepo:
      url: https://github.com/team-a/frontend
      path: k8s/overlays/prod
      branch: main
      targetNamespace: apps
  - name: backend
    gitRepo:
      url: https://github.com/team-a/backend
      path: k8s/overlays/prod
      targetNamespace: apps
```

#### Setting Resource Limits
```yaml
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

### Troubleshooting
#### Common Issues
1. **Namespace Creation Fails**
   - Error: `Error from server (Forbidden): namespaces is forbidden`
   - Solution: Ensure you have cluster-admin privileges
   - Command: `kubectl auth can-i create namespace --all-namespaces`

2. **Resource Quota Exceeded**
   - Error: `Error from server (Forbidden): exceeded quota`
   - Check current usage: `kubectl describe resourcequota -n <namespace>`
   - Adjust limits in input.yaml if necessary

#### Debugging
- Enable verbose logging:
  ```bash
  kubectl get events -n <namespace> --sort-by='.lastTimestamp'
  ```
- View RBAC permissions:
  ```bash
  kubectl auth can-i --list --namespace=<namespace>
  ```

## Infrastructure

![Infrastructure diagram](./docs/infra.svg)
### Namespaces
- `team-a-prod-apps`: Production applications namespace for Team A
- `team-a-prod-tools`: Tools namespace for Team A

### Network Policies
- `team-a-prod-apps-deny-all`: Default deny policy for apps namespace
- `team-a-prod-tools-deny-all`: Default deny policy for tools namespace
- `team-a-prod-apps-shared-services`: Allows access to shared services
- `team-a-prod-tools-shared-services`: Allows access to shared services

### RBAC
- Role: `apps-admin-admin` with full namespace access
- Role: `tools-developer-developer` with limited namespace access
- RoleBindings: Mapping roles to IAM users/groups

### Resource Management
- ResourceQuota: Limits CPU (4 cores), memory (8Gi), and pods (20)
- LimitRange: Default container limits and requests