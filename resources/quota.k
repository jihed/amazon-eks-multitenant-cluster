# resources/quota.k
import k8s.api.core.v1 as corev1
import base.config

quotas = [corev1.ResourceQuota {
    metadata = {
        name = "${ns}-quota"
        namespace = ns
    }
    spec = {
        hard = tenant.resourceQuota
    }
} for tenant in config.tenants for ns in tenant.namespaces]