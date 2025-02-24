# main.k
import resources.namespace
import resources.quota
import resources.limits
import resources.network

{
    apiVersion = "v1"
    kind = "List"
    items = namespace.namespaces + quota.quotas + limits.limits + network.policies
}