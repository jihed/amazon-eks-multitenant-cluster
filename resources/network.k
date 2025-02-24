# resources/network.k
import k8s.api.networking.v1 as networkingv1

tenants = option("tenants") or []

policies = [networkingv1.NetworkPolicy {
    metadata = {
        name = "${ns}-netpol"
        namespace = ns
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
                                team = t["name"]
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
        egress = [
            {
                to = [
                    {
                        namespaceSelector = {
                            matchLabels = {
                                team = t["name"]
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
} for t in tenants for ns in t["namespaces"]]