# Flux and Helm 3 Operator 
Configures Kubernetes cluster (for example AKS) for GitOps management

**fluxcd/helm-operator for helm3 support is not stable yet!**

> This module waits for terraform helm provider (https://www.terraform.io/docs/providers/helm/index.html) to support version 3, so flux can be configured properly.

## Prerequisites

You need to have `helm` version 3 binary installed locally

## Sample usage

```hcl-terraform
module "aks" {
  source  = "jacops/aks-cluster/azurerm"
  version = "0.1.1"

  location = "uksouth"
}

module "fluxcd" {
  source  = "jacops/fluxcd/kubernetes"
  version = "0.1.0"

  kube_config_raw = module.aks.cluster.kube_config_raw
  git_url         = "git@github.com:jacops/cicd-cluster-state.git"
}

resource "github_repository_deploy_key" "aks_cluster_state" {
  key        = module.fluxcd.git_ssh_public_key
  repository = "cicd-cluster-state"
  title      = "aks_cluster_state"
}
```
