region         = "ap-northeast-2"
cluster_name   = "prod-eks"
cluster_version = "1.28"
environment     = "prod"

vpc_cidr        = "10.0.0.0/16"
azs             = ["ap-northeast-2a", "ap-northeast-2c"]
private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

domain_name = "example.com"

node_groups = {
  management = {
    name           = "management-node-group"
    instance_types = ["t3.medium"]
    min_size       = 2
    max_size       = 4
    desired_size   = 2
    disk_size      = 50
    labels = {
      role = "management"
    }
  },
  application = {
    name           = "application-node-group"
    instance_types = ["t3.medium"]
    min_size       = 3
    max_size       = 10
    desired_size   = 3
    disk_size      = 100
    labels = {
      role = "application"
    }
  },
  monitoring = {
    name           = "monitoring-node-group"
    instance_types = ["t3.medium"]
    min_size       = 2
    max_size       = 4
    desired_size   = 2
    disk_size      = 100
    labels = {
      role = "monitoring"
    }
  }
}

tags = {
  Environment = "prod"
  Terraform   = "true"
  Project     = "eks-cluster"
}
