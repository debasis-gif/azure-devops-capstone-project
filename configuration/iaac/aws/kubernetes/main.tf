#
# aws --version
# aws eks --region ap-southeast-1 update-kubeconfig --name kalkey-cluster
# Uses default VPC and Subnet. Create Your Own VPC and Private Subnets for Prod Usage.
# terraform-backend-state-kalkey-123
#

terraform {
  backend "s3" {
    bucket = "mybucket" # Will be overridden from build
    key    = "path/to/my/key" # Will be overridden from build
    region = "us-east-1"
  }
}

resource "aws_default_vpc" "default" {
}

### Uncomment this section after cluster creation ###
# data "aws_eks_cluster" "example" {
#  name = "kalkey-cluster"
#}

# data "aws_eks_cluster_auth" "example" {
#  name = "kalkey-cluster"
#}

### Uncomment this section after cluster creation - take out the "#" ###
provider "kubernetes" {
### Uncomment this section after cluster creation - take out the "#"  ###
#  version                = "1.11.3"    // newly added property
#  host                   = data.aws_eks_cluster.example.endpoint
#  cluster_ca_certificate = base64decode(data.aws_eks_cluster.example.certificate_authority[0].data)
#  token                  = data.aws_eks_cluster_auth.example.token
#  load_config_file       = false      // newly added property
### Uncomment this section after cluster creation ###
}

module "kalkey-cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"   // changed to the version no. according to source module

  cluster_name    = "kalkey-cluster"
  cluster_version = "1.32"   // changed to the latest K8S cluster version 

  subnet_ids         = ["subnet-084434d0d9ae9ae64", "subnet-0e6d0e49f0c3c9e5d", "subnet-060b20ee750943f5e"] #CHANGE # subnets for Singapore
  #subnets = data.aws_subnet_ids.subnets.ids
  vpc_id          = aws_default_vpc.default.id  // Picking up the default VPC of Singapore
  #vpc_id         = "vpc-1234556abcdef"

  # Newly added entry to allow connection to the api server, without this change the error will continue
  cluster_endpoint_public_access  = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2023_x86_64_STANDARD"
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t2.medium"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      instance_types = ["t2.medium"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}

### Uncomment this section after cluster creation ###
# resource "kubernetes_cluster_role_binding" "example" {
#  metadata {
#    name = "fabric8-rbac"
#  }
#  role_ref {
#    api_group = "rbac.authorization.k8s.io"
#    kind      = "ClusterRole"
#    name      = "cluster-admin"
#  }
#  subject {
#    kind      = "ServiceAccount"
#    name      = "default"
#    namespace = "default"
#  }
# }

# resource "kubernetes_secret" "example" {
#  metadata {
#    annotations = {
#      "kubernetes.io/service-account.name" = "default"
#    }
#
#    generate_name = "terraform-default-"
#  }
#
#  type                           = "kubernetes.io/service-account-token"
### wait_for_service_account_token = true // Not needed for Kubernetes provider version 1.11.3
# }
### Uncomment this section after cluster creation, except line no. 111 ###

# Needed to set the default region
provider "aws" {
  version = "~> 5.8"
  region  = "ap-southeast-1"
}
