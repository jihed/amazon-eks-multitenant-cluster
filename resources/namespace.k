# resources/namespace.k
import k8s.api.core.v1 as corev1
import base.config

namespaces = [corev1.Namespace {
    metadata = {
        name = "${tenant.name}-${ns}"
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
} for tenant in config.tenants for ns in tenant.namespaces]