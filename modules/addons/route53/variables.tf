variable "domain_name" {
  description = "Domain name for Route53 zone"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "api_endpoint" {
  description = "API server endpoint"
  type        = string
  default     = ""
}

variable "api_endpoint_zone_id" {
  description = "Zone ID of the API server endpoint"
  type        = string
  default     = ""
}

variable "nlb_hostname" {
  description = "Hostname of the NLB for wildcard record"
  type        = string
  default     = ""
}

variable "nlb_zone_id" {
  description = "Zone ID of the NLB"
  type        = string
  default     = ""
}