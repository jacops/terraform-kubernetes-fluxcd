output "git_ssh_public_key" {
  value       = tls_private_key.fluxcd.public_key_openssh
  description = "Deploy key for your git repository"
}
