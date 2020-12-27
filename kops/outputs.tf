output "cluster_yaml" {
  value = local.cluster_yaml
}

output "nodes_yaml" {
  value = local.nodes_yaml
}

output "masters_yaml" {
  value = local.masters_yaml
}

output "kops_state" {
  value = local.kops_state
}

output "kops_cluster_name" {
  value = local.kops_cluster_name
}

output "kops_ssh_key" {
  value = tls_private_key.kops_private_key.private_key_pem
}
