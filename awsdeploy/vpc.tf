# VPC configuration

resource "aws_vpc" "service-vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${var.appname}-vpc"
    Environment = var.appenv
  }
}
