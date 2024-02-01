# create a namespace for cert-manager resources
resource "kubernetes_namespace" "cert-manager-ns" {
  metadata {
    name = var.namespace
  }
}
# create a cert-manager release
resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v${var.chart_version}"

  namespace = kubernetes_namespace.cert-manager-ns.metadata[0].name

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# create a cert-manager letsencrypt ClusterIssuer
# cannot use kubernetes_manifest resource since it practically 
# doesn't support CRDs. Going with kubectl instead.
resource "kubernetes_manifest" "letsencrypt" {
  manifest = yamldecode(<<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: stefan@zenml.io
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: nginx
YAML
  )
  depends_on = [
    resource.helm_release.cert-manager
  ]
}
