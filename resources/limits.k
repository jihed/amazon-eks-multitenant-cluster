# resources/limits.k
import k8s.api.core.v1 as corev1

tenants = option("tenants") or []

limits = [corev1.LimitRange {
    metadata = {
        name = "${ns}-limits"
        namespace = ns
    }
    spec = {
        limits = [{
            type = "Container"
            default = t["limitRange"]["default"]
            defaultRequest = t["limitRange"]["defaultRequest"]
            max = t["limitRange"]["max"]
        }]
    }
} for t in tenants for ns in t["namespaces"]]