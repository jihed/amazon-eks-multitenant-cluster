# resources/namespace.k
import k8s.api.core.v1 as corev1
import base.config

namespaces = [corev1.Namespace {
    metadata = {
        name = ns
        labels = {
            "team" = config.tenant.name
            "environment" = config.tenant.env
            "managed-by" = "kcl"
        }
        annotations = {
            "team.kubernetes.io/name" = config.tenant.name
            "team.kubernetes.io/environment" = config.tenant.env
        }
    }
} for ns in config.tenant.namespaces]