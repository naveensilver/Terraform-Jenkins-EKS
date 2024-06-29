variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "public_subnets" {
  description = "Subnets CIDR"
  type        = list(string)
}

# Instance type variable

variable "instance_type" {
    description = "Instance Type"
    type = string
}