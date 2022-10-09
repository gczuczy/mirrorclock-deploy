# used variables
# Right now everything goes by the default values. In a real-world setup
# the actual applied values are applied from a separate terraform.tfvars file,
# unique to each deployment.

variable "appname" {
  description = "The name of our application"
  type = string
  default = "mirrorclock-standalone"
}

variable "appversion" {
  description = "The version of the app to deploy"
  type = string
  default = "0.4"
}

variable "appname_short" {
  description = "Short name of the application"
  type = string
  default = "mc"
}

variable "appenv" {
  description = "The application environment"
  type = string
  default = "UAT"
}

variable "aws_region" {
  description = "AWS region to work in"
  type = string
  default = "eu-central-1"
}

variable "ecr_repo" {
  description = "Name of the ECR repository"
  type = string
  default = "mirrorclock-standalone"
}

variable "vpc_cidr" {
  description = "CIDR block to use for the VPC"
  type = string
  default = "10.13.37.0/24"
}

variable "private_subnets" {
  description = "Private subnet address ranges"
  type = list(string)
  default = [
    "10.13.37.0/28",
    "10.13.37.16/28",
  ]
}

variable "public_subnets" {
  description = "Private subnet address ranges"
  type = list(string)
  default = [
    "10.13.37.32/28",
    "10.13.37.48/28",
  ]
}

# to get the availabile zones in the region:
# ECR is practically an EC2 service, so it's the EC2 AZs
# aws --region $region ec2 describe-availability-zones
variable "availability_zones" {
  description = "Availability zones to use in region"
  type = list(string)
  default = [
    "eu-central-1a",
    "eu-central-1b",
  ]
}

