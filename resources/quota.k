# resources/quota.k
import k8s.api.core.v1 as corev1
import base.config

quotas = [corev1.ResourceQuota {
    metadata = {
        name = "${tenant.name}-quota"
        namespace = "${tenant.name}-${ns}"
        labels = {
            "team" = tenant.name
            "environment" = tenant.env
            "managed-by" = "kcl"
        }
        annotations = {
            "team.kubernetes.io/name" = tenant.name
            "team.kubernetes.io/environment" = tenant.env
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