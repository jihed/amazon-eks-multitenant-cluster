import base.config
import resources.namespace as namespace_res
import resources.quota as quota_res
import resources.limits as limits_res
import resources.network as network_res
import resources.rbac as rbac

{
    apiVersion = "v1"
    kind = "List"
    items = [
        {
            apiVersion = "v1"
            kind = "Namespace"
            metadata = ns.metadata
        } for ns in namespace_res.namespaces
    ] + [
        {
            apiVersion = "v1"
            kind = "ResourceQuota"
            metadata = quota.metadata
            spec = quota.spec
        } for quota in quota_res.quotas
    ] + [
        {
            apiVersion = "v1"
            kind = "LimitRange"
            metadata = limit.metadata
            spec = limit.spec
        } for limit in limits_res.limits
    ] + [
        {
            apiVersion = "networking.k8s.io/v1"
            kind = "NetworkPolicy"
            metadata = policy.metadata
            spec = policy.spec
        } for policy in network_res.all_policies
    ] + rbac.rbac_resources
}