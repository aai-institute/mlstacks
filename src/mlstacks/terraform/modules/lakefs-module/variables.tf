variable "namespace" {
  type    = string
  default = "lakefs"
}

variable "chart_version" {
  type    = string
  default = "1.2.5"
}

variable "ingress_host" {
  type    = string
  default = ""
}

variable "tls_enabled" {
  type    = bool
  default = true
}

variable "istio_enabled" {
  type    = bool
  default = false
}

# Database-related variables
variable "database_type" {
  type = string
  validation {
    condition     = contains(["postgres", "local"], var.database_type)
    error_message = "database_type must be any of: [postgres, local]"
  }
}

variable "database_postgres" {
  type = object({
    connection_string       = string,
    max_open_connections    = optional(number),
    max_idle_connections    = optional(number),
    connection_max_lifetime = optional(string),
  })
  description = "See lakeFS server configuration docs, section `database.postgresql`: https://docs.lakefs.io/reference/configuration.html"
  default     = null
}

# Storage-related variables
variable "storage_type" {
  type = string
  validation {
    condition     = contains(["gs", "s3"], var.storage_type)
    error_message = "storage_type must be any of: [gs, s3]"
  }
}

# General storage variables
variable "storage_bucket" {
  type        = string
  description = "Bucket name for object storage (automatically prepeded with appropriate protocol)"
  default     = ""
}

# GCS storage variables
variable "storage_gcs" {
  type = object({
    credentials_json = string,
  })
  description = "GCS storage configuration, see section `blockstore.gs`: https://docs.lakefs.io/reference/configuration.html"
  default     = null
  sensitive   = true
}

# S3(-like) storage variables
variable "storage_s3" {
  type = object({
    access_key_id     = string,
    secret_access_key = string,
    endpoint_url      = optional(string),
    region            = optional(string, "us-east1"),
    force_path_style  = optional(bool, false)
  })
  description = "S3 storage configuration, see section `blockstore.s3`: https://docs.lakefs.io/reference/configuration.html"
  default     = null
  sensitive   = true
}
