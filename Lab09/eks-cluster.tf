module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.28"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default_node_group = {
      desired_capacity = var.desired_capacity
      max_capacity     = 3
      min_capacity     = 1

      instance_types = [var.node_instance_type]
    }
  }

  tags = {
    "Project" = "eks-lab"
  }
}

data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks] # Asegura que el clúster se cree antes.
}

data "aws_eks_cluster_auth" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks] # Añadido para evitar dependencias no cumplidas.
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapUsers = <<EOT
    - userarn: arn:aws:iam::800917983494:user/paulotoro
      groups:
        - system:masters
    EOT
  }
}

data "aws_region" "current" {}
