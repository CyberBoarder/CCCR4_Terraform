output "role_arn" {
  description = "ARN of the IAM role for EFS CSI Driver"
  value       = module.efs_csi_driver_role.iam_role_arn
}

output "file_system_id" {
  description = "ID of the EFS file system"
  value       = aws_efs_file_system.eks.id
}

output "storage_class_name" {
  description = "Name of the EFS storage class"
  value       = kubernetes_storage_class.efs_sc.metadata[0].name
}