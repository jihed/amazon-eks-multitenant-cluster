# resources/limits.k
import k8s.api.core.v1 as corev1
import base.config

limits = [corev1.LimitRange {
    metadata = {
        name = "${ns}-limits"
        namespace = ns
        labels = {
            "managed-by" = "kcl"
        }
    }
    spec.limits = [{
        type = "Container"
        default = {
            "cpu" = tenant.limitRange.default.cpu
            "memory" = tenant.limitRange.default.memory
        }
        defaultRequest = {
            "cpu" = tenant.limitRange.defaultRequest.cpu
            "memory" = tenant.limitRange.defaultRequest.memory
        }
        max = {
            "cpu" = tenant.limitRange.max.cpu
            "memory" = tenant.limitRange.max.memory
        }
    }]
} for tenant in config.tenants for ns in tenant.namespaces]