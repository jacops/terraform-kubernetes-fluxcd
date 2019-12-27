terraform {
  required_version = ">= 0.12.2"

  required_providers {
    kubernetes = "~> 1.10"
    local      = ">= 1.4"
    tls        = ">= 2.1"
    random     = ">= 2.2"
  }
}

resource "tls_private_key" "fluxcd" {
  algorithm = "RSA"
  rsa_bits  = 4096

  count = var.generate_ssh_key && var.ssh_private_key == "" ? 1 : 0
}

resource "kubernetes_namespace" "fluxcd" {
  metadata {
    name = "fluxcd"
  }

  count = var.namespace == "" ? 1 : 0
}

resource "kubernetes_secret" "flux_ssh" {
  metadata {
    name      = "flux-ssh"
    namespace = local.flux_namespace
  }

  data = {
    identity = var.ssh_private_key != "" ? var.ssh_private_key : concat(tls_private_key.fluxcd.*.private_key_pem, [""])[0]
  }

  lifecycle {
    ignore_changes = [ metadata[0].annotations ]
  }

  count = var.generate_ssh_key || var.ssh_private_key != "" ? 1 : 0
}

locals {
  helm_install_script = "${path.module}/scripts/helm-install.sh"
  flux_namespace      = coalesce(var.namespace, concat(kubernetes_namespace.fluxcd.*.metadata.0.name, [""])[0])

  flux_environment = {
    KUBECONFIG         = var.kubeconfig_filename
    NAMESPACE          = local.flux_namespace
    CHART_NAME         = "fluxcd/flux"
    CHART_VERSION      = var.flux_chart_version
    RELEASE_NAME       = "flux"
    YAML_VALUES        = yamlencode(local.flux_values)
    YAML_CUSTOM_VALUES = yamlencode(var.flux_values)
  }
  helm_operator_environment = {
    KUBECONFIG         = var.kubeconfig_filename
    NAMESPACE          = local.flux_namespace
    CHART_NAME         = "fluxcd/helm-operator"
    CHART_VERSION      = var.helm_operator_chart_version
    RELEASE_NAME       = "helm-operator"
    YAML_VALUES        = yamlencode(local.helm_operator_values)
    YAML_CUSTOM_VALUES = yamlencode(var.helm_operator_values)
  }
}

resource "null_resource" "flux" {

  provisioner "local-exec" {
    on_failure  = fail
    command     = local.helm_install_script
    environment = local.flux_environment
  }

  provisioner "local-exec" {
    command     = "helm delete flux --namespace ${local.flux_namespace}"
    environment = local.flux_environment
    when        = destroy
  }

  triggers = local.flux_environment
}

resource "null_resource" "helm_operator" {

  provisioner "local-exec" {
    on_failure  = fail
    command     = local.helm_install_script
    environment = local.helm_operator_environment
  }

  provisioner "local-exec" {
    command     = "helm delete helm-operator --namespace ${local.flux_namespace}"
    environment = local.helm_operator_environment
    when        = destroy
  }

  provisioner "local-exec" {
    command     = "kubectl delete -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/flux-helm-release-crd.yaml"
    environment = local.helm_operator_environment
    when        = destroy
  }

  triggers = local.helm_operator_environment
}
