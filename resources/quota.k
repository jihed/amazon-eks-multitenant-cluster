# resources/quota.k
import k8s.api.core.v1 as corev1

tenants = option("tenants") or []

quotas = [corev1.ResourceQuota {
    metadata = {
        name = "${ns}-quota"
        namespace = ns
    }
    spec = {
        hard = t["resourceQuota"]
    }
} for t in tenants for ns in t["namespaces"]]