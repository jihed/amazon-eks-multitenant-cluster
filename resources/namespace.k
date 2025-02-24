# resources/namespace.k
import k8s.api.core.v1 as corev1
import base.config

namespaces = [corev1.Namespace {
    metadata = {
        name = ns
        labels = {
            team = tenant.name
            environment = tenant.env
            "kubernetes.io/metadata.name" = ns
        }
    }
} for tenant in config.tenants for ns in tenant.namespaces]