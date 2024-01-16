output "base_url" {
  description = "Base URL for the lakeFS web interface"
  value       = "${var.tls_enabled ? "https" : "http"}://${var.ingress_host}"
}

output "admin" {
  description = "Credentials for the automatically created admin user"
  value = {
    username      = local.lakefsConfig.installation.user_name
    access_key_id = local.lakefsConfig.installation.access_key_id
    secret_key    = local.lakefsConfig.installation.secret_access_key
  }
}
