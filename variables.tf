variable "kube_config_raw" {
  type        = string
  description = "Kubernetes config which will be stored in KUBECONFIG file"
}

variable "git_url" {
  type        = string
  description = "URL of git repo with Kubernetes manifests; e.g. git.url=ssh://git@github.com/fluxcd/flux-get-started"
}
