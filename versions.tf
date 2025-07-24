terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws        = { source = "hashicorp/aws",        version = ">= 4.60.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.13.0" }
    helm       = { source = "hashicorp/helm",       version = ">= 2.5.0" }
  }
}