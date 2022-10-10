
# adding a nat GW for the private subnets

resource "aws_eip" "nat-eip" {
  vpc = true
  depends_on = [var.igw_id]
  tags = {
    Name = "${var.appname_short}-NAT-IP"
  }
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id = var.public_subnet_id
}

resource "aws_route_table" "private-natgw-route" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = {
    Name = "${var.appname_short}-private-route-table"
  }
}

resource "aws_route_table_association" "private-route-assoc" {
  for_each = toset(var.private_subnet_ids)
  subnet_id = each.key
  route_table_id = aws_route_table.private-natgw-route.id
}
