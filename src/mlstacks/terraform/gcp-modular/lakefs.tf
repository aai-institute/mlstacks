module "lakefs" {
  source = "./lakefs-gcp"

  count = var.enable_data_lake_lakefs ? 1 : 0

  depends_on = [
    google_container_cluster.gke,
    null_resource.configure-local-kubectl,
    module.cert-manager,
    module.nginx-ingress,
  ]

  project_id   = var.project_id
  region       = var.region
  vpc_id       = module.vpc[0].network_id
  ingress_host = "${module.nginx-ingress[0].ingress-ip-address}.nip.io"
}
