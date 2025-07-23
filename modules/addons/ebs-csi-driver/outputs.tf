output "role_arn" {
  description = "ARN of the IAM role for EBS CSI Driver"
  value       = module.ebs_csi_driver_role.iam_role_arn
}

output "storage_class_name" {
  description = "Name of the default EBS storage class"
  value       = kubernetes_storage_class.ebs_sc.metadata[0].name
}