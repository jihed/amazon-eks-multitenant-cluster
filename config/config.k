# config/config.k
import yaml
import base.schema as s

# Default configurations
defaultQuota = {
    "cpu": "4"
    "memory": "8Gi"
    "pods": "20"
    "services": "10"
    "configmaps": "20"
    "secrets": "20"
}

defaultLimits = {
    "default": {
        "cpu": "500m"
        "memory": "512Mi"
    }
    "defaultRequest": {
        "cpu": "100m"
        "memory": "128Mi"
    }
    "max": {
        "cpu": "2"
        "memory": "2Gi"
    }
}

# Read all tenant files from the tenants directory
tenantFiles = [
    yaml.decode(read("config/tenants/${file}")) 
    for file in listdir("config/tenants") 
    if file.endswith(".yaml")
]

# Generate tenants with full namespace names
tenants = [
    s.Tenant {
        name = t.name
        env = t.env
        namespaces = ["${t.name}-${ns}" for ns in t.namespaces]
        resourceQuota = t.quota or defaultQuota
        limitRange = t.limits or defaultLimits
    } for t in tenantFiles
]