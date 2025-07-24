provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
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
  
  # Provide actual values for alias records
  api_endpoint         = module.eks.cluster_endpoint
  api_endpoint_zone_id = "Z1H1FL5HABSF5" # AWS 기본 API 엔드포인트 Zone ID
  nlb_hostname         = "" # 실제 배포 시 module.aws_lb_controller.nlb_hostname 값으로 대체
  nlb_zone_id          = "" # 실제 배포 시 module.aws_lb_controller.nlb_zone_id 값으로 대체
  
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