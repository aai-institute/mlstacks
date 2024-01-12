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

# Storage-related variables
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
  type    = string
  default = ""
}
variable "storage_S3_Secret_Key" {
  type    = string
  default = ""
}
variable "storage_S3_Endpoint_URL" {
  type    = string
  default = ""
}
