locals {
  name = "aws-ebs-csi-driver"
}

module "ebs_csi_driver_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name             = "${var.cluster_name}-${local.name}"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = replace(var.cluster_oidc_issuer_url, "https://", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/")
      namespace_service_accounts = ["kube-system:${local.name}"]
    }
  }
}

resource "helm_release" "ebs_csi_driver" {
  name       = local.name
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  version    = "2.23.1"

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
    value = module.ebs_csi_driver_role.iam_role_arn
  }
}

# Create a default storage class for EBS volumes
resource "kubernetes_storage_class" "ebs_sc" {
  metadata {
    name = "ebs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type      = "gp3"
    encrypted = "true"
  }

  depends_on = [helm_release.ebs_csi_driver]
}

data "aws_caller_identity" "current" {}