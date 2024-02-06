locals {
  # lakeFS server config to be passed into values.yaml template
  lakefsConfig = {
    database = {
      type = "${var.database_type}"
      # filter sensitive information (passed through k8s secrets)
      postgres = { for k, v in var.database_postgres : k => v if k != "connection_string" }
    }

    # admin user bootstrap is only applicable for local k/v store
    installation = var.database_type != "local" ? null : {
      user_name         = "admin"
      access_key_id     = "admin"
      secret_access_key = "supersafepassword"
    }

    # disable usage analytics
    stats = {
      enabled = false
    }

    blockstore = {
      type                     = "${var.storage_type}"
      default_namespace_prefix = "${var.storage_type}://${var.storage_bucket}/"
      gs = var.storage_type != "gs" ? null : {
        credentials_json : var.storage_gcs.credentials_json
      }
      s3 = var.storage_type != "s3" ? null : {
        region           = var.storage_s3.region,
        endpoint         = var.storage_s3.endpoint_url
        force_path_style = true
        credentials = {
          access_key_id     = var.storage_s3.access_key_id
          secret_access_key = var.storage_s3.secret_access_key
        }
      }
    }
  }
}
