output "git_ssh_public_key" {
  value       = concat(tls_private_key.fluxcd.*.public_key_openssh, [""])[0]
  description = "Deploy key for your git repository"
}
