module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 15.0.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id  = var.vpc_id
  subnets = var.subnet_ids

  # Enable OIDC provider for the cluster
  enable_irsa = true

  # Enable EKS Cluster CloudWatch logging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Cluster access configuration
  cluster_endpoint_public_access = true

  # Node groups
  node_groups = var.node_groups

  tags = var.tags
}