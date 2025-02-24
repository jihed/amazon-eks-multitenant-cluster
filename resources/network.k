# resources/network.k
import k8s.api.networking.v1 as networkingv1
import base.config

policies = [networkingv1.NetworkPolicy {
    metadata = {
        name = "${tenant.name}-${ns}-netpol"
        namespace = "${tenant.name}-${ns}"
        labels = {
            "team" = tenant.name
            "environment" = tenant.env
            "managed-by" = "kcl"
        }
        annotations = {
            "team.kubernetes.io/name" = tenant.name
            "team.kubernetes.io/environment" = tenant.env
        }
    }
    spec = {
        podSelector = {}
        policyTypes = ["Ingress", "Egress"]
        ingress = [
            {
                from = [
                    {
                        namespaceSelector = {
                            matchLabels = {
                                "team" = tenant.name
                            }
                        }
                    }
                    {
                        namespaceSelector = {
                            matchLabels = {
                                "kubernetes.io/metadata.name" = "kube-system"
                            }
                        }
                    }
                ]
                ports = [
                    {
                        port = 53
                        protocol = "UDP"
                    }
                    {
                        port = 53
                        protocol = "TCP"
                    }
                ]
            }
        ]
    }
} for tenant in config.tenants for ns in tenant.namespaces]