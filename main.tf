provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  vpc_name       = "${var.cluster_name}-vpc"
  vpc_cidr       = var.vpc_cidr
  azs            = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  cluster_name   = var.cluster_name
  
  tags = var.tags
}

module "eks" {
  source = "./modules/eks"
  
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  node_groups     = var.node_groups
  
  tags = var.tags
  
  depends_on = [module.vpc]
}

module "aws_lb_controller" {
  source = "./modules/addons/aws-lb-controller"
  
  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  vpc_id                  = module.vpc.vpc_id
  region                  = var.region
  
  depends_on = [module.eks]
}

module "ebs_csi_driver" {
  source = "./modules/addons/ebs-csi-driver"
  
  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  
  depends_on = [module.eks]
}

module "external_dns" {
  source = "./modules/addons/external-dns"
  
  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  domain_filter           = var.domain_name
  
  depends_on = [module.eks]
}

module "route53" {
  source = "./modules/addons/route53"
  
  domain_name     = var.domain_name
  environment     = var.environment
  cluster_name    = module.eks.cluster_name
  
  # These values would be populated when you have actual load balancers
  # api_endpoint         = module.eks.cluster_endpoint
  # api_endpoint_zone_id = "EXAMPLE_ZONE_ID"
  # nlb_hostname         = module.aws_lb_controller.nlb_hostname
  # nlb_zone_id          = module.aws_lb_controller.nlb_zone_id
  
  depends_on = [module.eks]
}

module "efs_csi_driver" {
  source = "./modules/addons/efs-csi-driver"
  
  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_subnets
  vpc_cidr_blocks         = [var.vpc_cidr]
  
  depends_on = [module.eks]
}