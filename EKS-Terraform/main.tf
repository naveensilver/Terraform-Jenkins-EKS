# Note : Here, we won't creating any modules directly but we make use of already existing modules

# VPC - Search "Terraform VPC Module"

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc" # Replace VPC name
  cidr = var.vpc_cidr  # using variable
  // cidr = "10.0.0.0/16"   

  azs = data.aws_availability_zones.azs.names
  // azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = var.private_subnets // we are deploying EKS cluster in Private subnet
  public_subnets = var.public_subnets

  enable_nat_gateway = true # enable because, we are using private subnets
  single_nat_gateway = true
  // enable_vpn_gateway = true
  
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/elb"               = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"      = 1
  }
}

// The Remaining things like internet gateways, route table and route table associations will be created automatically using this Existing AWS VPC module

# Create EKS - Search "AWS EKS Module"

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.24"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id           # Comes from VPC Module
  subnet_ids = module.vpc.private_subnets  # Comes from Private Subenets


# EKS Managed Node Group(s)
  eks_managed_node_groups = {
    nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_type = ["t2.small"]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}