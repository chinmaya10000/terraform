provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.23.0"

  cluster_name = "myapp-eks-cluster"
  cluster_version = "1.30"

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }

  eks_managed_node_groups = {
    dev = {
      
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t2.medium"]

      min_size     = 1
      max_size     = 3
      desired_size = 3
    }
  }
}