# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# Export Terraform output variable values to a stack yaml file 
# that can be consumed by zenml stack import
resource "local_file" "stack_file" {
  content  = <<-ADD
    # Stack configuration YAML
    # Generated by the AWS Modular MLOps stack recipe.
    zenml_version: ${var.zenml-version}
    stack_name: aws_modular_stack_${replace(substr(timestamp(), 0, 16), ":", "_")}
    components:
      artifact_store:
%{if var.enable_artifact_store}}      
        id: ${uuid()}
        flavor: s3
        name: s3_artifact_store
        configuration: {"path": "s3://${aws_s3_bucket.zenml-artifact-store[0].bucket}"}
%{else}
        id: ${uuid()}
        flavor: local
        name: default
        configuration: {}
%{endif}

%{if var.enable_container_registry}
      container_registry:
        id: ${uuid()}
        flavor: aws
        name: aws_container_registry
        configuration: {"uri": "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"}
%{endif}

      orchestrator:
%{if var.enable_orchestrator_kubeflow}      
        id: ${uuid()}
        flavor: kubeflow
        name: eks_kubeflow_orchestrator
        configuration: {"kubernetes_context": "${aws_eks_cluster.cluster[0].arn}", "synchronous": True}
%{else}
%{if var.enable_orchestrator_tekton}
        id: ${uuid()}
        flavor: tekton
        name: eks_tekton_orchestrator
        configuration: {"kubernetes_context": "${aws_eks_cluster.cluster[0].arn}"}
%{else}
%{if var.enable_orchestrator_kubernetes}
        id: ${uuid()}
        flavor: kubernetes
        name: eks_kubernetes_orchestrator
        configuration: {"kubernetes_context": "${aws_eks_cluster.cluster[0].arn}", "synchronous": True}
%{else}
        id: ${uuid()}
        flavor: local
        name: default
        configuration: {}
%{endif}
%{endif}
%{endif}

%{if var.enable_secrets_manager}
      secrets_manager:
        id: ${uuid()}
        flavor: aws
        name: aws_secrets_manager
        configuration: {"region_name": "${var.region}"}
%{endif}

%{if var.enable_experiment_tracker_mlflow}
      experiment_tracker:
        id: ${uuid()}
        flavor: mlflow
        name: eks_mlflow_experiment_tracker
        configuration: {"tracking_uri": "${var.enable_experiment_tracker_mlflow ? module.mlflow[0].mlflow-tracking-URL : ""}", "tracking_username": "${var.mlflow-username}", "tracking_password": "${var.mlflow-password}"}
%{endif}

%{if var.enable_model_deployer_kserve}
      model_deployer:
        id: ${uuid()}
        flavor: kserve
        name: eks_kserve_model_deployer
        configuration: {"kubernetes_context": "${aws_eks_cluster.cluster[0].arn}", "kubernetes_namespace": "${local.kserve.workloads_namespace}", "base_url": "${module.kserve[0].kserve-base-URL}", "secret": "aws_kserve_secret"}
%{endif}
%{if var.enable_model_deployer_seldon}
      model_deployer:
        id: ${uuid()}
        flavor: seldon
        name: eks_seldon_model_deployer
        configuration: {"kubernetes_context": "${aws_eks_cluster.cluster[0].arn}", "kubernetes_namespace": "${local.seldon.workloads_namespace}", "base_url": "http://${module.istio[0].ingress-hostname}:${module.istio[0].ingress-port}"}}
%{endif}
    ADD
  filename = "./aws_modular_stack_${replace(substr(timestamp(), 0, 16), ":", "_")}.yaml"
}
