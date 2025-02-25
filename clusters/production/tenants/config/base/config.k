# clusters/production/tenants/config/base/config.k
import yaml
import file
import base.schema as s

# Get specific tenant file and environment from env vars
tenant_file = option("TENANT_FILE") or ""
environment = option("ENVIRONMENT") or ""

# if not tenant_file:
#     assert "TENANT_FILE environment variable is required"
# if not environment:
#     assert "ENVIRONMENT environment variable is required"

print("Processing tenant file:", tenant_file)
print("Environment:", environment)

# Read and validate single tenant
tenant_data = yaml.decode(file.read(tenant_file))
tenant = s.Tenant {
    name = tenant_data.name
    env = environment  # Use environment from ApplicationSet
    namespaces = tenant_data.namespaces
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