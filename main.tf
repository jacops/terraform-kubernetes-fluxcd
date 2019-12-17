provider "random" {
  version = "~> 2.2"
}

provider "tls" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.4"
}

#######################################################################
######################## SETUP KUBECONFIG FILE ########################
#######################################################################

resource "random_id" "kubernetes_config" {
  byte_length = 8

  keepers = {
    config = var.kube_config_raw
  }
}

resource "local_file" "kubeconfig" {
  filename          = "/tmp/kubeconfig-${random_id.kubernetes_config.hex}"
  sensitive_content = var.kube_config_raw
  file_permission   = "0600"
}

#######################################################################
#######################################################################

provider "kubernetes" {
  version = "~> 1.10"

  load_config_file = local_file.kubeconfig.filename == "" ? false : true
  config_path      = local_file.kubeconfig.filename
}

resource "tls_private_key" "fluxcd" {
  algorithm = "RSA"
  rsa_bits  = 4096
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
    identity = tls_private_key.fluxcd.private_key_pem
  }

  lifecycle {
    ignore_changes = [ metadata[0].annotations ]
  }
}

locals {
  flux_install_script = "${path.module}/scripts/flux-install.sh"
}

resource "null_resource" "flux_install" {

  provisioner "local-exec" {
    on_failure  = fail
    command     = local.flux_install_script
    environment = {
      KUBECONFIG      = local_file.kubeconfig.filename
      GIT_SECRET_NAME = kubernetes_secret.flux_ssh.metadata.0.name
      GIT_URL         = var.git_url
    }
  }

  triggers = {
    flux_install_command = local.flux_install_script
    flux_script          = md5(file(local.flux_install_script))
    kube_config          = local_file.kubeconfig.filename
  }
}
