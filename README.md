# Flux and Helm 3 Operator 
Configures Kubernetes cluster (for example AKS) for GitOps management

**fluxcd/helm-operator for helm3 support is not stable yet!**

> This module waits for terraform helm provider (https://www.terraform.io/docs/providers/helm/index.html) to support version 3, so flux can be configured properly.

## Prerequisites

You need to have `helm` version 3 binary installed locally

## Sample usage

```hcl-terraform
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "my-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "my-cluster"
  cluster_version = "1.14"
  subnets         = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  vpc_id          = "vpc-1234556abcdef"

  worker_groups = [
    {
      instance_type = "m4.large"
      asg_max_size  = 5
    }
  ]
}

module "fluxcd" {
  source  = "jacops/fluxcd/kubernetes"
  version = "0.2.0"

  kubeconfig_filename = module.eks.kubeconfig_filename
  generate_ssh_key    = true
  flux_values         = {
    git = {
      pollInterval: "1m"
    }
  }
}

resource "github_repository_deploy_key" "aks_cluster_state" {
  key        = module.fluxcd.git_ssh_public_key
  repository = "cicd-cluster-state"
  title      = "eks_cluster_state"
}
```
