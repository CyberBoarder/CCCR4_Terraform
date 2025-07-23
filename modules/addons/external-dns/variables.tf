variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  type        = string
}

variable "domain_filter" {
  description = "Domain name to filter Route53 zones (e.g., example.com)"
  type        = string
}