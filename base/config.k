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
    resourceQuota = tenant.resourceQuota
    limitRange = tenant.limitRange
} for tenant in [yaml.decode(file.read(yaml_path)) for yaml_path in yaml_files]]