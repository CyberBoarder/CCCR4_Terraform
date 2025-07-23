locals {
  name = "external-dns"
}

module "external_dns_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name                     = "${var.cluster_name}-${local.name}"
  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = ["*"]

  oidc_providers = {
    main = {
      provider_arn               = replace(var.cluster_oidc_issuer_url, "https://", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/")
      namespace_service_accounts = ["kube-system:${local.name}"]
    }
  }
}

resource "helm_release" "external_dns" {
  name       = local.name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  namespace  = "kube-system"
  version    = "6.20.4"

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "aws.region"
    value = data.aws_region.current.name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = local.name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.external_dns_role.iam_role_arn
  }

  set {
    name  = "domainFilters[0]"
    value = var.domain_filter
  }

  set {
    name  = "policy"
    value = "sync"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}