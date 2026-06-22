resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "58.2.1" # Using a recent stable version

  set {
    name  = "grafana.fullnameOverride"
    value = "grafana"
  }

  depends_on = [kubernetes_namespace.monitoring]
}
