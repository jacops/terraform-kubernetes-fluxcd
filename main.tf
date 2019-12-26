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
}

resource "kubernetes_secret" "flux_ssh" {
  metadata {
    name      = "flux-ssh"
    namespace = kubernetes_namespace.fluxcd.metadata.0.name
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
  flux_install_script      = "${path.module}/scripts/flux-install.sh"
  flux_install_environment = {
    KUBECONFIG                  = var.kubeconfig_filename
    FLUX_CHART_VERSION          = var.flux_chart_version
    FLUX_YAML_VALUES            = yamlencode(local.flux_values)
    HELM_OPERATOR_CHART_VERSION = var.helm_operator_chart_version
    HELM_OPERATOR_YAML_VALUES   = yamlencode(local.helm_operator_values)
  }
}

resource "null_resource" "flux_install" {

  provisioner "local-exec" {
    on_failure  = fail
    command     = local.flux_install_script
    environment = local.flux_install_environment
  }

  triggers = local.flux_install_environment
}
