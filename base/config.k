# base/config.k
import base.schema as s

# import file
# import yaml

# yaml_files = file.glob("../tenants-onboarding/team-*.yaml")

# yamls = [ yaml.decode(file.read(yaml_path)) for yaml_path in yaml_files]


# Export tenants variable
tenants = [
    s.Tenant {
        name = "team-a"
        env = "production"
        namespaces = ["team-a-ns1", "team-a-ns2"]
        resourceQuota = {
            "cpu": "4"
            "memory": "8Gi"
            "pods": "20"
            "services": "10"
            "configmaps": "20"
            "secrets": "20"
        }
        limitRange = {
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
    }
]