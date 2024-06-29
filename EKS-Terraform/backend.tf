terraform {
  backend "s3" {
    bucket = "my-bucket-aws-s3"          # Replace s3 bucket name
    key    = "eks/terraform.tfstate"     # key - To store tfstate file
    region = "us-east-1"
  }
}

# Note : Make sure that you don't make use of variables in this particular block it is recommended to add actual values