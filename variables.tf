variable "kubeconfig_filename" {
  type        = string
  description = "Path to kubeconfig"
}

variable "flux_chart_version" {
  type        = string
  description = "Flux chart version"
  default     = "0.16.0"
}

variable "helm_operator_chart_version" {
  type        = string
  description = "Helm operator chart version"
  default     = "0.4.0"
}

variable "flux_values" {
  type        = object({})
  description = "Helm values for flux release"
  default     = {}
}

variable "helm_operator_values" {
  type        = object({})
  description = "Helm values for helm operator release"
  default     = {}
}

variable "generate_ssh_key" {
  type        = bool
  description = "Generate SSH key"
  default     = false
}

variable "ssh_private_key" {
  type        = string
  description = "SSH private key for flux"
  default     = ""
}
