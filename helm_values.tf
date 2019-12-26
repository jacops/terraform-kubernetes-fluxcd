locals {
  flux_values = merge(
    {
      git = {
        secretName: concat(kubernetes_secret.flux_ssh.*.metadata.0.name, [""])[0]
      }
    },
    var.flux_values
  )
  helm_operator_values = merge(
    {
      createCRD: true
      git: {
        ssh: {
          secretName: concat(kubernetes_secret.flux_ssh.*.metadata.0.name, [""])[0]
        }
      }
      helm: {
        versions: "v3"
      }
    },
    var.helm_operator_values
  )
}
