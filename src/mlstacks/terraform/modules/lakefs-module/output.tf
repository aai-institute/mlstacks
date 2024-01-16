output "base_url" {
  value = "${var.tls_enabled ? "https" : "http"}://${var.ingress_host}"
}

output "admin" {
  value = {
    username      = local.lakefsConfig.installation.user_name
    access_key_id = local.lakefsConfig.installation.access_key_id
    secret_key    = local.lakefsConfig.installation.secret_access_key
  }
}
