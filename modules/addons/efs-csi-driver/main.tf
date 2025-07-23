locals {
  name = "aws-efs-csi-driver"
}

module "efs_csi_driver_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name             = "${var.cluster_name}-${local.name}"
  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = replace(var.cluster_oidc_issuer_url, "https://", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/")
      namespace_service_accounts = ["kube-system:${local.name}"]
    }
  }
}

# Create EFS file system
resource "aws_efs_file_system" "eks" {
  creation_token = "${var.cluster_name}-efs"
  encrypted      = true
  
  tags = {
    Name = "${var.cluster_name}-efs"
  }
}

# Create mount targets in each private subnet
resource "aws_efs_mount_target" "eks" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.eks.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}

# Security group for EFS
resource "aws_security_group" "efs" {
  name        = "${var.cluster_name}-efs-sg"
  description = "Security group for EFS mount targets"
  vpc_id      = var.vpc_id

  ingress {
    description = "NFS from EKS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-efs-sg"
  }
}

# Install EFS CSI Driver using Helm
resource "helm_release" "efs_csi_driver" {
  name       = local.name
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  namespace  = "kube-system"
  version    = "2.4.8"

  set {
    name  = "controller.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = local.name
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.efs_csi_driver_role.iam_role_arn
  }
}

# Create storage class for EFS
resource "kubernetes_storage_class" "efs_sc" {
  metadata {
    name = "efs-sc"
  }

  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.eks.id
    directoryPerms   = "700"
  }

  depends_on = [helm_release.efs_csi_driver]
}

data "aws_caller_identity" "current" {}