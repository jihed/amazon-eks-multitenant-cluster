import yaml
import file

schema ResourceQuotaSpec:
    cpu: str
    memory: str
    pods: str

schema NetworkPolicySpec:
    enabled: bool = False
    allowedNamespaces?: [str]

schema Tenant:
    name: str
    labels?: {str:str}
    resourceQuota?: ResourceQuotaSpec
    networkPolicy?: NetworkPolicySpec

# Get tenants from settings
# Load the YAML configuration
configData = yaml.decode(file.read("tenant-config.yaml"))

tenants = configData.tenants

# Generate namespace for each tenant
namespaces = [
    {
        apiVersion = "v1"
        kind = "Namespace"
        metadata.name = tenant.name
        metadata.labels = tenant.labels
    } for tenant in tenants
]

# Generate resource quotas
resourceQuotas = [
    {
        apiVersion = "v1"
        kind = "ResourceQuota"
        metadata.name = "${tenant.name}-quota"
        metadata.namespace = tenant.name
        spec.hard = {
            cpu = tenant.resourceQuota.cpu
            memory = tenant.resourceQuota.memory
            pods = tenant.resourceQuota.pods
        }
    } for tenant in tenants if tenant.resourceQuota
]

# Generate network policies
networkPolicies = [
    {
        apiVersion = "networking.k8s.io/v1"
        kind = "NetworkPolicy"
        metadata.name = "${tenant.name}-network-policy"
        metadata.namespace = tenant.name
        spec = {
            podSelector = {}
            policyTypes = ["Ingress"]
            ingress = [
                {
                    from = [
                        {
                            namespaceSelector.matchLabels = {
                                "kubernetes.io/metadata.name" = ns
                            }
                        } for ns in tenant.networkPolicy.allowedNamespaces
                    ]
                }
            ]
        }
    } for tenant in tenants if tenant.networkPolicy?.enabled
]

# Combine all resources
manifests = namespaces + resourceQuotas + networkPolicies