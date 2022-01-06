# >>> defination of NAT gateway for private ec2's to 
# connect securely over the internet

# >>> EIP elastic IP
resource "aws_eip" "app-vpc-nat" {
  vpc = true
}

resource "aws_nat_gateway" "app-vpc-nat-gw" {
  allocation_id = aws_eip.app-vpc-nat.id
  subnet_id = aws_subnet.app-public-sub-1-a.id
  depends_on = [
    aws_internet_gateway.app-vpc-igw
  ]
  tags = {
      Name = "${var.ENVIRONMENT}-app-vpc-nat-gw"
  }
}

# >>> Private route table for private subnets
resource "aws_route_table" "app-vpc-private-rtb" {
  vpc_id = aws_vpc.app-vpc.id
  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.app-vpc-nat-gw.id
  }
  tags = {
     Name = "${var.ENVIRONMENT}-app-vpc-private-rtb"
  }
}

# >>> Routing table association with two pprivate subnets
resource "aws_route_table_association" "app-vpc-private-sub-1-a" {
  subnet_id = aws_subnet.app-private-sub-1-a.id
  route_table_id = aws_route_table.app-vpc-private-rtb.id
}

resource "aws_route_table_association" "app-vpc-private-sub-2-a" {
  subnet_id = aws_subnet.app-private-sub-2-b.id
  route_table_id = aws_route_table.app-vpc-private-rtb.id
}

