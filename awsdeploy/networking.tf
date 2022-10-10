resource "aws_internet_gateway" "mc-igw" {
  vpc_id = aws_vpc.service-vpc.id
  tags = {
    Name = "${var.appname_short}-igw"
    Environment = var.appenv
  }
}

resource "aws_subnet" "mc-private" {
  vpc_id = aws_vpc.service-vpc.id
  count = length(var.private_subnets)
  cidr_block = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.appname_short}-private-subnet-${count.index}"
    Environment = var.appenv
  }
}

resource "aws_subnet" "mc-public" {
  vpc_id = aws_vpc.service-vpc.id
  count = length(var.public_subnets)
  cidr_block = element(var.public_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.appname_short}-public-subnet-${count.index}"
    Environment = var.appenv
  }
}

resource "aws_route_table" "mc-public" {
  vpc_id = aws_vpc.service-vpc.id

  tags = {
    Name = "${var.appname_short}-routing-table-public"
    Environment = var.appenv
  }
}

resource "aws_route" "mc-public" {
  route_table_id = aws_route_table.mc-public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.mc-igw.id
}

resource "aws_route_table_association" "mc-public" {
  count = length(var.public_subnets)
  subnet_id = element(aws_subnet.mc-public.*.id, count.index)
  route_table_id = aws_route_table.mc-public.id
}

# https://aws.amazon.com/blogs/containers/aws-fargate-launches-platform-version-1-4/
# because we don't have any IPs assigned to our public instances, OR having them
# in a private subnet with a NatGW, we need to allow them to connect to the ECR
# we also need the S3 endpoint, because ECR is using S3 internally

# A SG to allow ecs tasks to the endpoint, it's an all out for now
resource "aws_security_group" "ecs-task-sg" {
  vpc_id = aws_vpc.service-vpc.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.appname_short}-service-sg"
    Environment = var.appenv
  }
}

#The S3 endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.service-vpc.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.mc-public.id]
  policy = data.aws_iam_policy_document.s3-ecr-access.json
}

# ECR Endpoints
resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id = aws_vpc.service-vpc.id
  private_dns_enabled = true
  service_name = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.ecs-task-sg.id]
  subnet_ids = aws_subnet.mc-public.*.id
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id = aws_vpc.service-vpc.id
  private_dns_enabled = true
  service_name = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.ecs-task-sg.id]
  #subnet_ids = concat(aws_subnet.mc-public.*.id, aws_subnet.mc-private.*.id)
  subnet_ids = aws_subnet.mc-public.*.id
}

resource "aws_vpc_endpoint" "ecs-agent" {
  vpc_id = aws_vpc.service-vpc.id
  private_dns_enabled = true
  service_name = "com.amazonaws.${var.aws_region}.ecs-agent"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.ecs-task-sg.id]
  subnet_ids = aws_subnet.mc-public.*.id
}

resource "aws_vpc_endpoint" "ecs-telemetry" {
  vpc_id = aws_vpc.service-vpc.id
  private_dns_enabled = true
  service_name = "com.amazonaws.${var.aws_region}.ecs-telemetry"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.ecs-task-sg.id]
  subnet_ids = aws_subnet.mc-public.*.id
}

resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id = aws_vpc.service-vpc.id
  private_dns_enabled = true
  service_name = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.ecs-task-sg.id]
  subnet_ids = aws_subnet.mc-public.*.id
}

# adding a natgw
# We add a single natGW for both of the private subnets. If per-AZ natGWs are needed
# for redundancy, we can call the module twice, once for each AZ, only supplying the
# private subnets belonging to the AZ, paired with their respecitve public one.

#module "natgw" {
#  source = "./modules/natgw"
#  vpc_id = aws_vpc.service-vpc.id
#  private_subnet_ids = aws_subnet.mc-private.*.id
#  public_subnet_id = aws_subnet.mc-public[0].id
#  igw_id = aws_internet_gateway.mc-igw.id
#  appname = var.appname
#  appname_short = var.appname_short
#}

