output "role_arn" {
  description = "ARN of the IAM role for External DNS"
  value       = module.external_dns_role.iam_role_arn
}