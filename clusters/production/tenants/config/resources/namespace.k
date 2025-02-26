import base.config
import base.common

namespaces = [{
    metadata = {
        name = "${config.tenant.prefix}-${ns}"
        labels = common.mergeLabels({
            "team": config.tenant.name
            "environment": config.tenant.env
        })
        annotations = common.mergeAnnotations({
            "team.kubernetes.io/name": config.tenant.name
            "team.kubernetes.io/environment": config.tenant.env
        })
    }
} for ns in config.tenant.namespaces]