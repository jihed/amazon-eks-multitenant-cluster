# resources/namespace.k
import k8s.api.core.v1 as corev1
import yaml

# Parse tenants data
tenants = option("tenants") or []

namespaces = [corev1.Namespace {
    metadata = {
        name = ns
        labels = {
            team = t["name"]
            environment = t["env"]
            "kubernetes.io/metadata.name" = ns
        }
    }
} for t in tenants for ns in t["namespaces"]]