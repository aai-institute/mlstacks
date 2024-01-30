variable "namespace" {
  type    = string
  default = "lakefs"
}

variable "chart_version" {
  type    = string
  default = "1.0.12"
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

# GCS storage variables
variable "storage_gcs_credentials_json" {
  type      = string
  sensitive = true
}

# S3(-like) storage variables
variable "storage_S3" {
  type    = bool
  default = false
}
variable "storage_S3_Region" {
  type    = string
  default = "us-east-1"
}
variable "storage_S3_Bucket" {
  type    = string
  default = ""
}
variable "storage_S3_Access_Key" {
  type      = string
  sensitive = true
  default   = ""
}
variable "storage_S3_Secret_Key" {
  type      = string
  sensitive = true
  default   = ""
}
variable "storage_S3_Endpoint_URL" {
  type    = string
  default = ""
}
