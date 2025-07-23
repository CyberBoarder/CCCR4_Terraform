variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster is deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EFS mount targets"
  type        = list(string)
}

variable "vpc_cidr_blocks" {
  description = "List of CIDR blocks for the VPC"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}