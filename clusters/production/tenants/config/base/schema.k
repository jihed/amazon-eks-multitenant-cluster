import regex

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

    if regex.match(r"^[a-zA-Z0-9][-a-zA-Z0-9]*[a-zA-Z0-9]$", name) == False:
        assert "Invalid tenant name format"
    if len(name) > 63:
        assert "Tenant name must be <= 63 characters"
    if env not in ["dev", "staging", "prod"]:
        assert "Environment must be dev, staging, or prod"
    if len(namespaces) == 0:
        assert "At least one namespace is required"