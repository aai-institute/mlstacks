module "lakefs" {
  source = "../modules/lakefs-module"

  count = var.enable_data_lake_lakefs ? 1 : 0

  # run only after the cluster, ingress controller, and minio are set up
  depends_on = [
    k3d_cluster.zenml-cluster,
    module.nginx-ingress,
    module.istio,
  ]

  # details about the lakefs deployment
  chart_version = local.lakefs.version
  ingress_host  = (var.enable_model_deployer_seldon) ? "${local.lakefs.ingress_host_prefix}.${module.istio[0].ingress-ip-address}.nip.io" : "${local.lakefs.ingress_host_prefix}.${module.nginx-ingress[0].ingress-ip-address}.nip.io"
  tls_enabled   = false
  istio_enabled = (var.enable_model_deployer_seldon) ? true : false

  database_type = "local"

  storage_type = "s3"
  storage_s3 = {
    endpoint_url      = module.minio_server[0].artifact_S3_Endpoint_URL
    access_key_id     = var.zenml-minio-store-access-key
    secret_access_key = var.zenml-minio-store-secret-key
    bucket            = minio_s3_bucket.lakefs[0].bucket
    force_path_style  = true
  }
}

resource "random_id" "lakefs_bucket_suffix" {
  byte_length = 4
}

# Create a bucket for lakeFS to use
resource "minio_s3_bucket" "lakefs" {
  count = (var.enable_data_lake_lakefs && var.lakefs_minio_bucket == "") ? 1 : 0

  bucket        = "lakefs-minio-${random_id.lakefs_bucket_suffix.hex}"
  force_destroy = true

  depends_on = [
    module.minio_server,
    module.nginx-ingress,
    module.istio,
  ]
}
