locals {
  flux_values = {
    git = {
      secretName: concat(kubernetes_secret.flux_ssh.*.metadata.0.name, [""])[0]
    }
  }
  helm_operator_values = {
    createCRD: true
    git: {
      ssh: {
        secretName: local.flux_values.git.secretName
      }
    }
    helm: {
      versions: "v3"
    }
  }
}
