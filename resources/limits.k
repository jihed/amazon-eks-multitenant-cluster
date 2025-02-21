# resources/limits.k
import k8s.api.core.v1 as corev1
import config.config as c

limits = [corev1.LimitRange {
    metadata = {
        name = "${ns}-limits"
        namespace = ns
    }
    spec = {
        limits = [{
            type = "Container"
            default = tenant.limitRange.default
            defaultRequest = tenant.limitRange.defaultRequest
            max = tenant.limitRange.max
        }]
    }
} for tenant in c.tenants for ns in tenant.namespaces]