output "role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller"
  value       = module.lb_controller_role.iam_role_arn
}