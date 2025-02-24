# main.k
import resources.namespace
import resources.quota
import resources.limits
import resources.network

# Output all resources
namespace.namespaces + quota.quotas + limits.limits + network.policies