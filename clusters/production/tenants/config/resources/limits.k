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
            "cpu" = config.tenant.limitRange.default.cpu
            "memory" = config.tenant.limitRange.default.memory
        }
        defaultRequest = {
            "cpu" = config.tenant.limitRange.defaultRequest.cpu
            "memory" = config.tenant.limitRange.defaultRequest.memory
        }
        max = {
            "cpu" = config.tenant.limitRange.max.cpu
            "memory" = config.tenant.limitRange.max.memory
        }
    }]
} for ns in config.tenant.namespaces]