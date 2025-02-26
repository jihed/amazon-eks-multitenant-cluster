import yaml
import file
import base.schema as s

tenant_file = option("TENANT_FILE") or ""

if not tenant_file:
    assert "TENANT_FILE environment variable is required"

print("Processing tenant file: ${tenant_file}")

tenant_data = yaml.decode(file.read(tenant_file))

# Validate tenant data structure
assert tenant_data, "Empty tenant configuration"
assert tenant_data.name, "Tenant name is required"
assert tenant_data.env, "Tenant environment is required"
assert tenant_data.namespaces, "Tenant namespaces are required"

# Create and export tenant configuration
tenant = s.Tenant {
    name = str(tenant_data.name)
    env = str(tenant_data.env)
    namespaces = [str(ns) for ns in tenant_data.namespaces]
    resourceQuota = s.ResourceQuota {
        cpu = tenant_data?.resourceQuota?.cpu
        memory = tenant_data?.resourceQuota?.memory
        pods = tenant_data?.resourceQuota?.pods
        services = tenant_data?.resourceQuota?.services
        configmaps = tenant_data?.resourceQuota?.configmaps
        secrets = tenant_data?.resourceQuota?.secrets
    }
    limitRange = s.LimitRange {
        default = s.ContainerLimits {
            cpu = tenant_data?.limitRange?.default?.cpu
            memory = tenant_data?.limitRange?.default?.memory
        }
        defaultRequest = s.ContainerLimits {
            cpu = tenant_data?.limitRange?.defaultRequest?.cpu
            memory = tenant_data?.limitRange?.defaultRequest?.memory
        }
        max = s.ContainerLimits {
            cpu = tenant_data?.limitRange?.max?.cpu
            memory = tenant_data?.limitRange?.max?.memory
        }
    }
}

# Export the tenant configuration
schema Config:
    tenant: s.Tenant

config = Config {
    tenant = tenant
}