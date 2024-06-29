# Use this data source to get the ID of a registered AMI for use in other resources.

# Create aws_ami data source

data "aws_ami" "example" {
  //executable_users = ["self"]
  most_recent = true
  //name_regex       = "^myami-\\d{3}"
  owners = ["amazon"] # Configure owners

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-hvm-*x86_64-gp2"] # Configure AMI Filter
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create one more data source for Aws Availability Zones

data "aws_availability_zones" "azs" {}