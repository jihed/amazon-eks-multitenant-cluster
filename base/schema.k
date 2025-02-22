# base/schema.k
schema Tenant:
    name: str
    env: str
    namespaces: [str]
    resourceQuota: {str:str}
    limitRange: {str:{str:str}}