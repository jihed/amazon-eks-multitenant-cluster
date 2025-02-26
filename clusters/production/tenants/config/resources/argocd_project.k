import base.config as config
import base.common as common


# Generate ArgoCD Project
argocd_project = [
    {
        apiVersion = "argoproj.io/v1alpha1"
        kind = "AppProject"
        metadata = {
            name = config.tenant.prefix
            namespace = "argocd"
            labels = common.mergeLabels({
                "team": config.tenant.name
                "environment": config.tenant.env
            })
            annotations = {
                "argocd.argoproj.io/sync-wave": "-1"
            }
        }
        spec = {
            description = "Project for ${config.tenant.name} team in ${config.tenant.env} environment"
            sourceRepos = [
                "https://github.com/${config.tenant.name}/*"
            ]
            destinations = [
                {
                    server = "https://kubernetes.default.svc"
                    namespace = "${config.tenant.prefix}-${ns}"
                } for ns in config.tenant.namespaces
            ]
            clusterResourceWhitelist = [
                {
                    group = ""
                    kind = "Namespace"
                }
            ]
            namespaceResourceWhitelist = [
                {
                    group = "*"
                    kind = "*"
                }
            ]
            roles = [
                {
                    name = "project-admin"
                    description = "Project admin role"
                    policies = [
                        "p, proj:${config.tenant.prefix}:project-admin, applications, *, ${config.tenant.prefix}/*, allow"
                    ]
                    groups = [
                        "${config.tenant.name}-admins"
                    ]
                }
                {
                    name = "project-readonly"
                    description = "Project read-only role"
                    policies = [
                        "p, proj:${config.tenant.prefix}:project-readonly, applications, get, ${config.tenant.prefix}/*, allow"
                    ]
                    groups = [
                        "${config.tenant.name}-viewers"
                    ]
                }
            ]
        }
    }
]