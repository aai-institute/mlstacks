module "lakefs" {
  source = "../modules/lakefs-module"

  count = var.enable_data_lake_lakefs ? 1 : 0

  # run only after the cluster, ingress controller, and minio are set up
  depends_on = [
    k3d_cluster.zenml-cluster,
    module.nginx-ingress,
    module.istio,
    module.minio_server,
    minio_s3_bucket.lakefs_bucket,
  ]

  # details about the lakefs deployment
  chart_version = local.lakefs.version
  ingress_host  = (var.enable_model_deployer_seldon) ? "${local.lakefs.ingress_host_prefix}.${module.istio[0].ingress-ip-address}.nip.io" : "${local.lakefs.ingress_host_prefix}.${module.nginx-ingress[0].ingress-ip-address}.nip.io"
  tls_enabled   = false
  istio_enabled = (var.enable_model_deployer_seldon) ? true : false

  database_type = "local"

  storage_type            = "s3"
  storage_S3_Access_Key   = var.zenml-minio-store-access-key
  storage_S3_Secret_Key   = var.zenml-minio-store-secret-key
  storage_S3_Bucket       = minio_s3_bucket.lakefs_bucket[0].bucket
  storage_S3_Endpoint_URL = module.minio_server[0].artifact_S3_Endpoint_URL
}

resource "random_string" "lakefs_bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Create a bucket for lakeFS to use
resource "minio_s3_bucket" "lakefs_bucket" {
  count = (var.enable_data_lake_lakefs && var.lakefs_minio_bucket == "") ? 1 : 0

  bucket        = "lakefs-minio-${random_string.lakefs_bucket_suffix.result}"
  force_destroy = true

  depends_on = [
    module.minio_server,
    module.nginx-ingress,
    module.istio,
  ]
}
