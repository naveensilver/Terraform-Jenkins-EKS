# Note : Here, we won't creating any modules directly but we make use of already existing modules

# VPC - Search "Terraform VPC Module"

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc" # Replace VPC name
  cidr = var.vpc_cidr  # using variable
  // cidr = "10.0.0.0/16"   

  azs = data.aws_availability_zones.azs.names
  // azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  // private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  // we won't making use of private subnets using only public and one public subnet is sufficient for us.
  public_subnets = var.public_subnets

  // enable_nat_gateway = true
  // enable_vpn_gateway = true
  map_public_ip_on_launch = true
  
  enable_dns_hostnames = true

  tags = {
    Name        = "jenkins-vpc"
    Terraform   = "true"
    Environment = "dev"
  }

  public_subnet_tags = {
    Name = "jenkins-subnet"
  }
  redshift_route_table_tags = {
    Name = "jenkins-rt"
  }
}

// The Remaining things like internet gateways, route table and route table associations will be created automatically using this Existing AWS VPC module

# SG - Search "Terraform Security Groups module"

module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "user-service"
  description = " Security Groups for Jenkins Server "
  vpc_id      = module.vpc.vpc_id # VPC ID COMES FROM ABOVE VPC MODULE

  //ingress_cidr_blocks      = ["10.10.0.0/16"]
  //ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "HTTP Port For Jenkins server"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH Port for Secure shell"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name = "jenkins-sg"
  }
}


# EC2 - Search "AWS EC2 Module"

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "Jenkins-Server"

  instance_type          = var.instance_type
  key_name               = "gitopskey"          # Replace with Your Keypair
  monitoring             = true
  vpc_security_group_ids = [module.sg.security_group_id]      # SG ID comes from SG module 
  subnet_id              = module.vpc.public_subnets[0]

  associate_public_ip_address = true
  user_data = file("Jenkins-tools.sh")
  availability_zone = data.aws_availability_zones.azs.names[0]



  tags = {
    Name = "Jenkins-Server"
    Terraform   = "true"
    Environment = "dev"
  }
}


