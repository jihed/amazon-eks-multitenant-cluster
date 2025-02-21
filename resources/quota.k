# resources/quota.k
import k8s.api.core.v1 as corev1
import config.config as c

quotas = [corev1.ResourceQuota {
    metadata = {
        name = "${ns}-quota"
        namespace = ns
    }
    spec = {
        hard = tenant.resourceQuota
    }
} for tenant in c.tenants for ns in tenant.namespaces]