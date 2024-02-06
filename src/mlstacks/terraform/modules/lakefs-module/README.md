<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.8 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0.1 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | 1.14.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.0.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.11.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.lakefs](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.lakefs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | n/a | `string` | `"1.1.3"` | no |
| <a name="input_database_postgres"></a> [database\_postgres](#input\_database\_postgres) | See lakeFS server configuration docs, section `database.postgresql`: https://docs.lakefs.io/reference/configuration.html | <pre>object({<br>    connection_string       = string,<br>    max_open_connections    = optional(number),<br>    max_idle_connections    = optional(number),<br>    connection_max_lifetime = optional(string),<br>  })</pre> | `null` | no |
| <a name="input_database_type"></a> [database\_type](#input\_database\_type) | Database-related variables | `string` | n/a | yes |
| <a name="input_ingress_host"></a> [ingress\_host](#input\_ingress\_host) | n/a | `string` | `""` | no |
| <a name="input_istio_enabled"></a> [istio\_enabled](#input\_istio\_enabled) | n/a | `bool` | `false` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | n/a | `string` | `"lakefs"` | no |
| <a name="input_storage_bucket"></a> [storage\_bucket](#input\_storage\_bucket) | Bucket name for object storage (automatically prepeded with appropriate protocol) | `string` | `""` | no |
| <a name="input_storage_gcs"></a> [storage\_gcs](#input\_storage\_gcs) | GCS storage configuration, see section `blockstore.gs`: https://docs.lakefs.io/reference/configuration.html | <pre>object({<br>    credentials_json = string,<br>  })</pre> | `null` | no |
| <a name="input_storage_s3"></a> [storage\_s3](#input\_storage\_s3) | S3 storage configuration, see section `blockstore.s3`: https://docs.lakefs.io/reference/configuration.html | <pre>object({<br>    access_key_id     = string,<br>    secret_access_key = string,<br>    endpoint_url      = optional(string),<br>    region            = optional(string, "us-east1"),<br>    force_path_style  = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Storage-related variables | `string` | n/a | yes |
| <a name="input_tls_enabled"></a> [tls\_enabled](#input\_tls\_enabled) | n/a | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin"></a> [admin](#output\_admin) | Credentials for the automatically created admin user |
| <a name="output_base_url"></a> [base\_url](#output\_base\_url) | Base URL for the lakeFS web interface |
<!-- END_TF_DOCS -->