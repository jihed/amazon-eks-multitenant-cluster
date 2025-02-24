# base/config.k
import yaml
import file
import base.schema as s

# Read all YAML files from tenants directory
yaml_files = file.glob("tenants/*.yaml")

# Convert YAML data to schema-validated tenants
tenants = [s.Tenant {
    name = tenant.name
    env = tenant.env
    namespaces = tenant.namespaces
    resourceQuota = s.ResourceQuota {
        cpu = tenant?.resourceQuota?.cpu
        memory = tenant?.resourceQuota?.memory
        pods = tenant?.resourceQuota?.pods
        services = tenant?.resourceQuota?.services
        configmaps = tenant?.resourceQuota?.configmaps
        secrets = tenant?.resourceQuota?.secrets
    }
    limitRange = s.LimitRange {
        default = s.ContainerLimits {
            cpu = tenant?.limitRange?.default?.cpu
            memory = tenant?.limitRange?.default?.memory
        }
        defaultRequest = s.ContainerLimits {
            cpu = tenant?.limitRange?.defaultRequest?.cpu
            memory = tenant?.limitRange?.defaultRequest?.memory
        }
        max = s.ContainerLimits {
            cpu = tenant?.limitRange?.max?.cpu
            memory = tenant?.limitRange?.max?.memory
        }
    }
} for tenant in [yaml.decode(file.read(yaml_path)) for yaml_path in yaml_files]]