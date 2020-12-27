locals {
  kops_cluster_name = "${var.cluster_name}.${var.domain}"
  kops_state = "s3://${aws_s3_bucket.kops_state.bucket}"
}

resource "aws_s3_bucket" "kops_state" {
  bucket = "kops.${local.kops_cluster_name}"
  force_destroy = true
}

resource "tls_private_key" "kops_private_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "kops_key_pair" {
  key_name = "kops_${local.kops_cluster_name}"
  public_key = tls_private_key.kops_private_key.public_key_openssh
}

locals {
  cluster_yaml = templatefile("${path.module}/templates/cluster.template.yaml", {
    k8s_version = var.k8s_version
    full_cluster_domain = local.kops_cluster_name
    cluster_store = local.kops_state
    master_public_domain = "api.${local.kops_cluster_name}"
    master_type = var.masters_instance_size
    master_subnets = var.masters_subnets
    dns_zone_id = var.dns_zone_id
    nodes = var.nodes
    vpc_id = var.vpc_id
    vpc_cidr = var.vpc_cidr
    public_subnets = var.public_subnets
    utility_subnets = var.utility_subnets
    private_subnets = var.private_subnets
    sshpublickey = aws_key_pair.kops_key_pair.public_key
  })

  nodes_yaml = join("$", [for k, v in var.nodes : templatefile("${path.module}/templates/node_group.template.yaml", {
    full_cluster_domain = local.kops_cluster_name
    node_group = k
    image = var.k8s_image
    node = var.nodes[k]
  })])

  masters_yaml = join("$", [for k, v in var.masters_subnets : templatefile("${path.module}/templates/master.template.yaml", {
    full_cluster_domain = local.kops_cluster_name
    image = var.k8s_image
    subnet = v
    machine_type = var.masters_instance_size
  })])
}
