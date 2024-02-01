module "lakefs" {
  source = "../modules/lakefs-module"

  count = var.enable_data_lake_lakefs ? 1 : 0

  depends_on = [
    google_container_cluster.gke,
    null_resource.configure-local-kubectl,
    module.cert-manager,
    module.nginx-ingress,
  ]

  # details about the lakefs deployment
  chart_version = local.lakefs.version

  database_type = "postgres"
  database_postgres = {
    connection_string = "postgresql://${google_sql_user.lakefs.name}:${google_sql_user.lakefs.password}@${google_sql_database_instance.instance.private_ip_address}:5432/${google_sql_database.lakefs.name}"
  }

  ingress_host = "${local.lakefs.ingress_host_prefix}.${module.nginx-ingress[0].ingress-ip-address}.nip.io"
  tls_enabled  = false

  storage_type                 = "gs"
  storage_gcs_credentials_json = base64decode(google_service_account_key.lakefs.private_key)
}

resource "random_string" "lakefs_bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}

## Storage Resources

# Create a bucket for lakeFS to use
resource "google_storage_bucket" "lakefs" {
  name     = "lakefs-${random_string.lakefs_bucket_suffix.result}"
  location = "EU"

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}

resource "google_service_account" "lakefs" {
  account_id   = "lakefs"
  display_name = "Service Account for lakeFS storage access"
}

resource "google_project_iam_binding" "lakefs" {
  project = var.project_id

  role = "roles/storage.objectUser"
  members = [
    "serviceAccount:${google_service_account.lakefs.email}",
  ]
}

resource "google_service_account_key" "lakefs" {
  service_account_id = google_service_account.lakefs.name
}

## Database Resources

resource "random_string" "lakefs_db_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "random_password" "lakefs_db" {
  length  = 16
  special = false
  upper   = true
}

resource "google_sql_database" "lakefs" {
  name     = "lakefs"
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "lakefs" {
  name     = "lakefs"
  instance = google_sql_database_instance.instance.name
  password = random_password.lakefs_db.result
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.vpc[0].network_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = module.vpc[0].network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database_instance" "instance" {
  name             = "lakefs-${random_string.lakefs_db_suffix.result}"
  region           = var.region
  database_version = "POSTGRES_15"
  depends_on       = [module.vpc[0]]

  settings {
    tier              = local.lakefs.database_instance_tier
    availability_type = "ZONAL"
    activation_policy = "ALWAYS"

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = module.vpc[0].network_id
      enable_private_path_for_google_cloud_services = true
    }
  }

  deletion_protection = true
}
