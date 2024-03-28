# create the lakeFS namespace
resource "kubernetes_namespace" "lakefs" {
  metadata {
    name = var.namespace
  }
}

# create the lakeFS deployment
resource "helm_release" "lakefs" {
  name       = "lakefs"
  repository = "https://charts.lakefs.io"
  chart      = "lakefs"
  version    = var.chart_version

  namespace = kubernetes_namespace.lakefs.metadata[0].name

  # set ingress 
  set {
    name  = "ingress.enabled"
    value = var.ingress_host != "" ? true : false
    type  = "auto"
  }
  set {
    name  = "ingress.ingressClassName"
    value = var.istio_enabled ? "istio" : "nginx"
    type  = "string"
  }
  set {
    name  = "ingress.hosts[0].host"
    value = var.ingress_host
    type  = "string"
  }
  set {
    name  = "ingress.hosts[0].paths[0]"
    value = "/"
    type  = "string"
  }
  set {
    name  = "ingress.hosts[0].paths[0].pathType"
    value = "Prefix"
    type  = "string"
  }
  dynamic "set" {
    for_each = var.tls_enabled ? [var.ingress_host] : []
    content {
      name  = "ingress.tls[0].hosts[0]"
      value = set.value
      type  = "string"
    }
  }
  dynamic "set" {
    for_each = var.tls_enabled ? ["lakefs-tls"] : []
    content {
      name  = "ingress.tls[0].secretName"
      value = set.value
      type  = "string"
    }
  }
  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/ssl-redirect"
    value = var.tls_enabled
    type  = "string"
  }

  # Sensitive configuration options
  dynamic "set" {
    for_each = var.database_type == "postgres" ? [var.database_postgres.connection_string] : []
    content {
      name  = "secrets.databaseConnectionString"
      value = set.value
    }
  }

  # template values.yaml with full config block
  values = [
    templatefile("${path.module}/values.yaml.tftpl", {
      config = local.lakefsConfig
    })
  ]
}
