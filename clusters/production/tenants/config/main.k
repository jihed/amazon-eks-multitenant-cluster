import base.config
import resources.namespace as namespace_res
import resources.quota as quota_res
import resources.limits as limits_res
import resources.network as network_res

# Create raw Kubernetes List object
{
    apiVersion = "v1"
    kind = "List"
    items = [
        # Namespaces
        {
            apiVersion = "v1"
            kind = "Namespace"
            metadata = ns.metadata
        } for ns in namespace_res.namespaces
    ] + [
        # Resource Quotas
        {
            apiVersion = "v1"
            kind = "ResourceQuota"
            metadata = quota.metadata
            spec = quota.spec
        } for quota in quota_res.quotas
    ] + [
        # Limit Ranges
        {
            apiVersion = "v1"
            kind = "LimitRange"
            metadata = limit.metadata
            spec = limit.spec
        } for limit in limits_res.limits
    ] + [
        # Network Policies
        {
            apiVersion = "networking.k8s.io/v1"
            kind = "NetworkPolicy"
            metadata = policy.metadata
            spec = policy.spec
        } for policy in network_res.all_policies
    ]
}