COMMON_LABELS = {
    "managed-by": "kcl"
    "app.kubernetes.io/managed-by": "kcl"
    "app.kubernetes.io/created-by": "tenant-operator"
}

COMMON_ANNOTATIONS = {
    "tenant-operator.kubernetes.io/version": "v1"
}

mergeLabels = lambda labels: {str:str} {
    COMMON_LABELS | labels
}

mergeAnnotations = lambda annotations: {str:str} {
    COMMON_ANNOTATIONS | annotations
}