# resources/quota.k
import k8s.api.core.v1 as corev1
import base.config

quotas = [corev1.ResourceQuota {
    metadata = {
        name = "${ns}-quota"
        namespace = ns
        labels = {
            "managed-by" = "kcl"
        }
    }
    spec = {
        hard = {
            "cpu" = tenant.resourceQuota.cpu
            "memory" = tenant.resourceQuota.memory
            "pods" = tenant.resourceQuota.pods
            "services" = tenant.resourceQuota.services
            "configmaps" = tenant.resourceQuota.configmaps
            "secrets" = tenant.resourceQuota.secrets
        }
    }
} for tenant in config.tenants for ns in tenant.namespaces]