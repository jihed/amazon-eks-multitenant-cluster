# clusters/production/tenants/config/base/schema.k
schema ResourceQuota:
    cpu?: str = "4"
    memory?: str = "8Gi"
    pods?: str = "20"
    services?: str = "10"
    configmaps?: str = "20"
    secrets?: str = "20"

schema ContainerLimits:
    cpu: str
    memory: str

schema LimitRange:
    default: ContainerLimits = {
        cpu = "500m"
        memory = "512Mi"
    }
    defaultRequest: ContainerLimits = {
        cpu = "100m"
        memory = "128Mi"
    }
    max: ContainerLimits = {
        cpu = "2"
        memory = "2Gi"
    }

schema Tenant:
    name: str
    env: str
    namespaces: [str]
    resourceQuota: ResourceQuota
    limitRange: LimitRange