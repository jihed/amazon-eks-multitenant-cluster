# Multi-Tenant Kubernetes Configuration on Amazon EKS with KCL

[Previous sections remain unchanged up to Application Onboarding]

## Platform Team Setup

Follow these steps to set up the multi-tenant environment in ArgoCD:

1. **Install ArgoCD KCL Plugin**
   ```yaml
   # Apply the KCL plugin configuration
   kubectl apply -f bootstrap/kcl-argocd-plugin.yaml
   ```

2. **Create ArgoCD Project**
   ```yaml
   # Apply the project configuration
   apiVersion: argoproj.io/v1alpha1
   kind: AppProject
   metadata:
     name: tenants-prod
     namespace: argocd
   spec:
     description: "Production Tenant Management"
     sourceRepos:
       - "https://github.com/jihed/amazon-eks-multitenant-cluster.git"
     destinations:
       - namespace: '*'
         server: https://kubernetes.default.svc
     clusterResourceWhitelist:
       - group: '*'
         kind: '*'
   ```

3. **Configure ApplicationSet**
   ```yaml
   # Apply the ApplicationSet configuration
   apiVersion: argoproj.io/v1alpha1
   kind: ApplicationSet
   metadata:
     name: prod-tenant-namespaces
     namespace: argocd
   spec:
     generators:
       - git:
           repoURL: https://github.com/jihed/amazon-eks-multitenant-cluster.git
           revision: HEAD
           files:
           - path: "clusters/production/tenants/config/*/input.yaml"
     template:
       metadata:
         name: 'prod-{{path.basename}}-tenant'
         namespace: argocd
         labels:
           tenant: '{{path.basename}}'
           environment: production
       spec:
         project: tenants-prod
         source:
           repoURL: https://github.com/jihed/amazon-eks-multitenant-cluster.git
           targetRevision: HEAD
           path: 'clusters/production/tenants/config'
           plugin:
             name: kcl-v1.0
             parameters:
               - name: TENANT_FILE
                 string: "{{path.basename}}/input.yaml"
               - name: ENVIRONMENT
                 string: "production"
         destination:
           server: https://kubernetes.default.svc
           namespace: '{{path.basename}}'
         syncPolicy:
           automated:
             prune: true
             selfHeal: true
   ```

4. **Verify Setup**
   ```bash
   # Check plugin installation
   kubectl get configmap kcl-plugin-config -n argocd

   # Verify project creation
   kubectl get appproject tenants-prod -n argocd

   # Check ApplicationSet
   kubectl get applicationset prod-tenant-namespaces -n argocd
   ```

5. **Directory Structure Setup**
   ```bash
   mkdir -p clusters/production/tenants/config
   ```

6. **Enable Auto-Sync**
   - Verify that the ApplicationSet controller is running
   - Check ArgoCD UI for automatic application creation
   - Monitor sync status for newly created applications

7. **Security Configuration**
   - Ensure ArgoCD has appropriate RBAC permissions
   - Verify access to the Git repository
   - Configure network access for the KCL plugin

8. **Monitoring Setup**
   ```bash
   # Check ApplicationSet controller logs
   kubectl logs -n argocd -l app.kubernetes.io/name=argocd-applicationset-controller

   # Monitor application creation
   kubectl get applications -n argocd -l environment=production
   ```

After completing these steps, the platform is ready for application teams to onboard their applications following the "Application Onboarding" process.

[Rest of the README remains unchanged]