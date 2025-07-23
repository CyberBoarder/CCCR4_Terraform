output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group IDs attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "route53_zone_id" {
  description = "The ID of the Route53 hosted zone"
  value       = module.route53.zone_id
}

output "route53_name_servers" {
  description = "The name servers of the Route53 hosted zone"
  value       = module.route53.name_servers
}

output "efs_file_system_id" {
  description = "ID of the EFS file system"
  value       = module.efs_csi_driver.file_system_id
}

output "efs_storage_class_name" {
  description = "Name of the EFS storage class"
  value       = module.efs_csi_driver.storage_class_name
}