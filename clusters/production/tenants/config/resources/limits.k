import base.config
import base.common

limits = [{
    metadata = {
        name = "${ns}-${config.tenant.env}-limits"  # Add environment suffix
        namespace = "${ns}-${config.tenant.env}"     # Match namespace name
        labels = common.mergeLabels({
            "team": config.tenant.name
        })
        annotations = common.mergeAnnotations({
            "team.kubernetes.io/limit-range": "true"
        })
    }
    spec = {
        limits = [{
            type = "Container"
            default = {
                "cpu": config.tenant.limitRange.default.cpu
                "memory": config.tenant.limitRange.default.memory
            }
            defaultRequest = {
                "cpu": config.tenant.limitRange.defaultRequest.cpu
                "memory": config.tenant.limitRange.defaultRequest.memory
            }
            max = {
                "cpu": config.tenant.limitRange.max.cpu
                "memory": config.tenant.limitRange.max.memory
            }
        }]
    }
} for ns in config.tenant.namespaces]