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
            "cpu" = config.tenant.resourceQuota.cpu
            "memory" = config.tenant.resourceQuota.memory
            "pods" = config.tenant.resourceQuota.pods
            "services" = config.tenant.resourceQuota.services
            "configmaps" = config.tenant.resourceQuota.configmaps
            "secrets" = config.tenant.resourceQuota.secrets
        }
    }
} for ns in config.tenant.namespaces]