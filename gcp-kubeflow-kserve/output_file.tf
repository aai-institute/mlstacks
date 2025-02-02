# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# Export Terraform output variable values to a stack yaml file 
# that can be consumed by zenml stack import
resource "local_file" "stack_file" {
  content  = <<-ADD
    # Stack configuration YAML
    # Generated by the GCP Kubeflow MLOps stack recipe.
    zenml_version: ${var.zenml-version}
    stack_name: gcp_kubeflow_stack_${replace(substr(timestamp(), 0, 16), ":", "_")}
    components:
      artifact_store:
        id: ${uuid()}
        flavor: gcp
        name: gcs_artifact_store
        configuration: {"path": "gs://${google_storage_bucket.artifact-store.name}"}
      container_registry:
        id: ${uuid()}
        flavor: gcp
        name: gcr_container_registry
        configuration: {"uri": "${local.container_registry.region}.gcr.io/${local.project_id}"}
      orchestrator:
        id: ${uuid()}
        flavor: kubeflow
        name: gke_kubeflow_orchestrator
        configuration: {"kubernetes_context": "gke_${local.project_id}_${local.region}_${module.gke.name}", "synchronous": True}
      secrets_manager:
        id: ${uuid()}
        flavor: gcp
        name: gcp_secrets_manager
        configuration: {"project_id": "${local.project_id}"}
      experiment_tracker:
        id: ${uuid()}
        flavor: mlflow
        name: gke_mlflow_experiment_tracker
        configuration: {"tracking_uri": "http://${data.kubernetes_service.mlflow_tracking.status.0.load_balancer.0.ingress.0.ip}", "tracking_username": "${var.mlflow-username}", "tracking_password": "${var.mlflow-password}"}
      model_deployer:
        id: ${uuid()}
        flavor: kserve
        name: gke_kserve
        configuration: {"kubernetes_context": "gke_${local.project_id}_${local.region}_${module.gke.name}", "kubernetes_namespace": "${local.kserve.workloads_namespace}", "base_url": "http://${data.kubernetes_service.kserve_ingress.status.0.load_balancer.0.ingress.0.ip}:${data.kubernetes_service.kserve_ingress.spec.0.port.1.port}", "secret": "gcp_kserve_secret"}
    ADD
  filename = "./gcp_kubeflow_stack_${replace(substr(timestamp(), 0, 16), ":", "_")}.yaml"
}
