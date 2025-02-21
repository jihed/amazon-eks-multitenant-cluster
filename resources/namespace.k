# resources/namespace.k
import k8s.api.core.v1 as corev1
import config.config as c

namespaces = [corev1.Namespace {
    metadata = {
        name = ns
        labels = {
            team = tenant.name
            environment = tenant.env
            "kubernetes.io/metadata.name" = ns
        }
    }
} for tenant in c.tenants for ns in tenant.namespaces]